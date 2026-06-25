import { Controller } from "@hotwired/stimulus"

// 画像選択後に、
// - ファイル形式・サイズを確認する
// - 画像を圧縮して JPEG 化する
// - 圧縮後の画像をフォーム送信用 input に入れ直す
// - プレビューを表示する
// - 親 controller に「有効な画像が選ばれた」と通知する
// controller
export default class extends Controller {
  // HTML 側の data-previews-target="..." と対応する要素
  //
  // input: 実際にフォーム送信される file input
  // preview: プレビュー全体を囲む要素
  // image: プレビューとして表示する img 要素
  static targets = ["input", "preview", "image"]

  // controller が画面に接続されたときに呼ばれる
  // Object URL を後で解放できるよう、初期値を持たせる
  connect() {
    this.previewUrl = null
  }

  // Turbo による画面更新や画面遷移などで、
  // controller が DOM から外れるときに呼ばれる
  //
  // 作成した Object URL を不要なまま残さないよう解放する
  disconnect() {
    this.revokePreviewUrl()
  }

  // file input の change イベントから呼ばれる
  async preview(event) {
    // ユーザーが選択した最初のファイルを取得する
    const originalFile = event.target.files[0]

    // 許可する MIME タイプ
    const validTypes = ["image/jpeg", "image/png"]

    // アップロード前の元ファイルの上限サイズ: 10MB
    const maxSizeInBytes = 10 * 1024 * 1024

    // ファイル選択をキャンセルした場合など
    if (!originalFile) {
      // input とプレビューを初期化する
      this.removeImage()
      return
    }

    // JPEG / PNG 以外は受け付けない
    if (!validTypes.includes(originalFile.type)) {
      alert("JPEG、JPG、PNG形式のファイルを選択してください。")
      this.removeImage()
      return
    }

    // 圧縮前のファイルが 10MB を超えていたら受け付けない
    if (originalFile.size > maxSizeInBytes) {
      alert("画像は10MB以下にしてください。")
      this.removeImage()
      return
    }

    try {
      // 画像を縮小・JPEG化した新しい File を作る
      const compressedFile = await this.compressImage(originalFile)

      // 開発中の確認用ログ
      console.log("圧縮前", {
        name: originalFile.name,
        type: originalFile.type,
        size: originalFile.size,
      })

      console.log("圧縮後", {
        name: compressedFile.name,
        type: compressedFile.type,
        size: compressedFile.size,
      })

      // file input の files は通常直接代入できないため、
      // DataTransfer を経由して圧縮後の File に差し替える
      const dataTransfer = new DataTransfer()
      dataTransfer.items.add(compressedFile)
      this.inputTarget.files = dataTransfer.files

      // 圧縮後の画像をプレビューに表示する
      this.showPreview(compressedFile)

      // 親の要素に "previews:valid-file-selected" イベントを送る
      //
      // 例:
      // data-action="previews:valid-file-selected->geolocation#fetchPosition"
      //
      // としていれば、このタイミングで位置情報取得を始められる
      this.dispatch("valid-file-selected")
    } catch (error) {
      // 画像読み込み・canvas 変換・Blob作成などに失敗した場合
      console.error("画像の圧縮に失敗しました", error)
      alert("画像の処理に失敗しました。もう一度選択してください。")
      this.removeImage()
    }
  }

  // 画像を最大 1600px に縮小し、JPEG の File として返す
  async compressImage(file) {
    // File を img 要素として読み込む
    const image = await this.loadImage(file)

    // 長辺の最大サイズ
    const maxSize = 1600

    // 元画像が 1600px 以下なら scale は 1 のまま
    // 大きい場合だけ、縦横比を保ったまま縮小する
    const scale = Math.min(
      1,
      maxSize / image.naturalWidth,
      maxSize / image.naturalHeight,
    )

    // 縮小後の画像サイズ
    const width = Math.round(image.naturalWidth * scale)
    const height = Math.round(image.naturalHeight * scale)

    // ブラウザ上で画像加工するための canvas を作る
    const canvas = document.createElement("canvas")
    canvas.width = width
    canvas.height = height

    // canvas に絵を描くための 2D コンテキストを取得する
    const context = canvas.getContext("2d")

    // PNG に透明部分がある場合、JPEG 化すると透明を保持できない
    // そのため、先に白背景を描いておく
    context.fillStyle = "#ffffff"
    context.fillRect(0, 0, width, height)

    // 元画像を canvas に縮小して描画する
    context.drawImage(image, 0, 0, width, height)

    // canvas の内容を JPEG Blob に変換する
    const blob = await new Promise((resolve, reject) => {
      canvas.toBlob(
        (result) => {
          if (result) {
            resolve(result)
          } else {
            reject(new Error("画像のBlobを作成できませんでした"))
          }
        },
        "image/jpeg",
        // JPEG の品質。1 に近いほど高画質・大容量
        0.8,
      )
    })

    // Blob をフォーム送信できる File に変換して返す
    return new File(
      [blob],
      // 元ファイル名の拡張子を jpg にする
      this.compressedFileName(file.name),
      {
        type: "image/jpeg",
        lastModified: Date.now(),
      },
    )
  }

  // File を img 要素として読み込む
  loadImage(file) {
    return new Promise((resolve, reject) => {
      const image = new Image()

      // File をブラウザ内で参照するための一時 URL を作る
      const imageUrl = URL.createObjectURL(file)

      // 読み込み成功時
      image.onload = () => {
        // 画像の読み込みが終わったので、この URL はもう不要
        URL.revokeObjectURL(imageUrl)
        resolve(image)
      }

      // 読み込み失敗時
      image.onerror = () => {
        // 失敗時も URL を解放する
        URL.revokeObjectURL(imageUrl)
        reject(new Error("画像を読み込めませんでした"))
      }

      // 作成した URL を指定して画像読み込みを開始する
      image.src = imageUrl
    })
  }

  // 元のファイル名の拡張子を jpg に変える
  //
  // photo.png -> photo.jpg
  // IMG_001.JPG -> IMG_001.jpg
  compressedFileName(originalName) {
    const baseName = originalName.replace(/\.[^/.]+$/, "")

    return `${baseName}.jpg`
  }

  // 圧縮後の File をプレビューとして表示する
  showPreview(file) {
    // すでに別画像の Object URL があれば、先に解放する
    this.revokePreviewUrl()

    // プレビュー表示用の Object URL を作る
    this.previewUrl = URL.createObjectURL(file)

    // img 要素に画像を表示する
    this.imageTarget.src = this.previewUrl

    // プレビュー領域を表示する
    this.previewTarget.style.display = "block"

    // ここにあった FileReader は削除してよい
    //
    // Object URL だけでプレビューできているため、
    // FileReader で Data URL を作る必要はない
  }

  // ファイル選択やプレビューを初期状態に戻す
  removeImage() {
    // フォーム送信対象のファイルを空にする
    this.inputTarget.value = ""

    // img 要素から画像を外す
    this.imageTarget.src = ""

    // プレビュー領域を隠す
    this.previewTarget.style.display = "none"

    // プレビュー用 Object URL を解放する
    this.revokePreviewUrl()
  }

  // showPreview で作った Object URL を解放する
  revokePreviewUrl() {
    // URL が作られていなければ何もしない
    if (!this.previewUrl) return

    // ブラウザに「この一時 URL はもう不要」と伝える
    URL.revokeObjectURL(this.previewUrl)

    // 解放済みであることを controller 側にも反映する
    this.previewUrl = null
  }
}