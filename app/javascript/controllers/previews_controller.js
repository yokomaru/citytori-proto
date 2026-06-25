import { Controller } from "@hotwired/stimulus";

// 画像選択時に、
// - ファイル形式・サイズを確認する
// - 画像を縮小・JPEG化する
// - 圧縮後の画像をフォーム送信対象に差し替える
// - プレビューを表示する
// - 有効な画像が選ばれたことを親要素へ通知する
// controller
export default class extends Controller {
  // HTML 側の data-previews-target="..." と対応する要素
  //
  // input: 実際にフォーム送信される file input
  // preview: プレビュー全体を囲む要素
  // image: プレビュー表示用の img 要素
  static targets = ["input", "preview", "image"];

  // controller が DOM に接続されたときに呼ばれる
  //
  // プレビュー表示用に作成する Object URL を後で解放できるよう、
  // 初期値を持たせる
  connect() {
    this.previewUrl = null;
  }

  // Turbo による画面更新や画面遷移などで、
  // controller が DOM から外れるときに呼ばれる
  //
  // 作成済みの Object URL を解放する
  disconnect() {
    this.revokePreviewUrl();
  }

  // file input の change イベントから呼ばれる
  async preview(event) {
    // ユーザーが選択した最初のファイルを取得する
    const originalFile = event.target.files[0];

    // 選択されたファイルが使えるか確認する
    const errorMessage = this.validateFile(originalFile);

    // ファイルが不正な場合は、理由を表示して入力・プレビューを初期化する
    if (errorMessage) {
      alert(errorMessage);
      this.removeImage();
      return;
    }

    try {
      // 元画像を縮小し、JPEG の File を作成する
      const compressedFile = await this.compressImage(originalFile);

      // 開発中の確認用ログ
      console.log("圧縮前", {
        name: originalFile.name,
        type: originalFile.type,
        size: originalFile.size,
      });

      console.log("圧縮後", {
        name: compressedFile.name,
        type: compressedFile.type,
        size: compressedFile.size,
      });

      // file input の files は通常直接変更できないため、
      // DataTransfer を使って圧縮後の File に差し替える
      const dataTransfer = new DataTransfer();
      dataTransfer.items.add(compressedFile);
      this.inputTarget.files = dataTransfer.files;

      // 圧縮後の画像を画面に表示する
      this.showPreview(compressedFile);

      // 親要素に "previews:valid-file-selected" イベントを送る
      //
      // 例:
      // data-action="previews:valid-file-selected->geolocation#fetchPosition"
      //
      // としていれば、画像選択後に位置情報取得を始められる
      this.dispatch("valid-file-selected");
    } catch (error) {
      // 画像読み込み、canvas 描画、Blob 作成などに失敗した場合
      console.error("画像の圧縮に失敗しました", error);
      alert("画像の処理に失敗しました。もう一度選択してください。");
      this.removeImage();
    }
  }

  // ファイル形式と圧縮前サイズを確認する
  //
  // 問題がなければ null、
  // 問題があれば表示用のエラーメッセージを返す
  validateFile(file) {
    // 受け付ける MIME タイプ
    const validTypes = ["image/jpeg", "image/png"];

    // 圧縮前のファイルサイズ上限: 10MB
    const maxSizeInBytes = 10 * 1024 * 1024;

    // ファイル選択をキャンセルした場合などは、
    // エラーにせず後続の処理を止める
    if (!file) {
      return null;
    }

    // JPEG / PNG 以外は受け付けない
    if (!validTypes.includes(file.type)) {
      return "JPEG、JPG、PNG形式のファイルを選択してください。";
    }

    // 圧縮前のサイズが大きすぎる場合は受け付けない
    if (file.size > maxSizeInBytes) {
      return "画像は10MB以下にしてください。";
    }

    return null;
  }

  // 画像を最大 1600px に縮小し、
  // JPEG の File として返す
  async compressImage(file) {
    // File を img 要素として読み込む
    const image = await this.loadImage(file);

    // 縦・横のうち長い方の最大サイズ
    const maxSize = 1600;

    // 1600px 以下なら scale は 1 のまま、
    // 大きければ縦横比を保ったまま縮小する
    const scale = Math.min(
      1,
      maxSize / image.naturalWidth,
      maxSize / image.naturalHeight,
    );

    // 縮小後の幅・高さ
    const width = Math.round(image.naturalWidth * scale);
    const height = Math.round(image.naturalHeight * scale);

    // 開発中の確認用ログ
    console.log("圧縮後の画像サイズ", { width, height });

    // ブラウザ上で画像を加工するための canvas を作る
    const canvas = document.createElement("canvas");
    canvas.width = width;
    canvas.height = height;

    // canvas に描画するための 2D コンテキストを取得する
    const context = canvas.getContext("2d");

    // PNG の透明部分は JPEG では保持できないため、
    // 透明部分がある場合は白背景になるよう先に塗る
    context.fillStyle = "#ffffff";
    context.fillRect(0, 0, width, height);

    // 元画像を canvas に縮小して描画する
    context.drawImage(image, 0, 0, width, height);

    // canvas の内容を JPEG Blob に変換する
    const blob = await new Promise((resolve, reject) => {
      canvas.toBlob(
        (result) => {
          if (result) {
            resolve(result);
          } else {
            reject(new Error("画像のBlobを作成できませんでした"));
          }
        },
        "image/jpeg",
        // JPEG の画質。1 に近いほど高画質・大容量になる
        0.8,
      );
    });

    // Blob をフォーム送信用の File に変換して返す
    return new File([blob], this.compressedFileName(file.name), {
      type: "image/jpeg",
      lastModified: Date.now(),
    });
  }

  // File を img 要素として読み込む
  loadImage(file) {
    return new Promise((resolve, reject) => {
      const image = new Image();

      // File をブラウザ内で参照するための一時 URL を作る
      const imageUrl = URL.createObjectURL(file);

      // 画像の読み込みに成功した場合
      image.onload = () => {
        // 画像の読み込み後は、この URL は不要なので解放する
        URL.revokeObjectURL(imageUrl);
        resolve(image);
      };

      // 画像の読み込みに失敗した場合
      image.onerror = () => {
        // 失敗時も URL を解放する
        URL.revokeObjectURL(imageUrl);
        reject(new Error("画像を読み込めませんでした"));
      };

      // 一時 URL を指定して画像の読み込みを開始する
      image.src = imageUrl;
    });
  }

  // 元ファイル名の拡張子を jpg に変える
  //
  // photo.png -> photo.jpg
  // IMG_001.JPG -> IMG_001.jpg
  compressedFileName(originalName) {
    const baseName = originalName.replace(/\.[^/.]+$/, "");

    return `${baseName}.jpg`;
  }

  // 圧縮後の File をプレビューとして表示する
  showPreview(file) {
    // すでに別画像の Object URL があれば先に解放する
    this.revokePreviewUrl();

    // プレビュー表示用の一時 URL を作る
    this.previewUrl = URL.createObjectURL(file);

    // img 要素に圧縮後の画像を表示する
    this.imageTarget.src = this.previewUrl;

    // プレビュー領域を表示する
    this.previewTarget.style.display = "block";
  }

  // file input とプレビューを初期状態へ戻す
  removeImage() {
    // フォーム送信対象のファイルを空にする
    this.inputTarget.value = "";

    // img 要素に設定している画像を外す
    this.imageTarget.src = "";

    // プレビュー領域を隠す
    this.previewTarget.style.display = "none";

    // プレビュー用の Object URL を解放する
    this.revokePreviewUrl();
  }

  // showPreview で作った Object URL を解放する
  revokePreviewUrl() {
    // まだ Object URL を作っていない場合は何もしない
    if (!this.previewUrl) return;

    // ブラウザに「この一時 URL は不要」と伝える
    URL.revokeObjectURL(this.previewUrl);

    // controller 側でも解放済みとして扱う
    this.previewUrl = null;
  }
}
