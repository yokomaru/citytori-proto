import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  // ターゲットの定義
  static targets = ["input", "preview", "image"];
  // デバッグ用のログ出力
  connect() {
    console.log("Preview controller connected");
  }

  preview(event) {
    //選択された最初のファイルを変数fileに格納
    const file = event.target.files[0];
    // const maxSizeInBytes = 10 * 1024 * 1024; // 10MB
    const validTypes = ["image/jpeg", "image/jpg", "image/png"];

    if (!file) {
      this.removeImage();
      return;
    }

    // MIMEタイプのチェック
    if (!validTypes.includes(file.type)) {
      // 不正なファイル形式の場合のアラート表示
      alert("JPEG、JPG、PNG形式のファイルを選択してください。");
      this.removeImage();
      return;
    }

    // if (file.size < maxSizeInBytes) {
    //readerをfilereaderオブジェクトとして定義
    // 有効な画像が選択されたことを親要素へ通知する
    this.dispatch("valid-file-selected");
      //readerをfilereaderオブジェクトとして定義
    const reader = new FileReader();
      // ファイルをデータURLとして読み込む
    reader.readAsDataURL(file);
      // readerにファイル読み込み完了時の処理を定義
      reader.onload = (e) => {
        // 読み込んだデータをプレビュー画像のsrcに設定,e.targetでイベントを発生させたFilereaderオブジェクトを取得
        this.imageTarget.src = e.target.result;
        // プレビューエリアのhiddenクラスを削除して表示
        this.previewTarget.classList.remove("hidden");
        this.previewTarget.style.display = "block"
      // };
    // } else {
    //   // ファイルが大きすぎる場合のアラート表示
    //   alert("ファイルサイズは10MB以下にしてください。");
    //   this.removeImage();
    // }
      }
  }

  // 画像削除処理
  removeImage() {
    this.inputTarget.value = "";
    this.imageTarget.src = "";
    this.previewTarget.classList.add("hidden");
  }

  // デバッグ用
  disconnect() {
    // this.revokeCurrentObjectURL();
    this.previewTarget.style.display = "none"
    console.log("Preview controller disconnected");
  }
}
