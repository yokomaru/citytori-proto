import { Controller } from "@hotwired/stimulus";

// ステップ登録フォームのモーダル表示・非表示や、
// Turbo Stream 送信後のフォーム初期化を担当する controller
export default class extends Controller {
  // HTML 側の data-step-form-target="..." と対応する要素
  //
  // modal: モーダル全体を囲む背景要素
  // errors: バリデーションエラーを表示する領域
  static targets = ["modal", "errors"];

  // 「写真を撮る」などのボタンから呼ばれる
  //
  // モーダルを開く前に、前回表示されたエラーを消す
  open() {
    this.clearErrors();
    this.modalTarget.style.display = "flex";
  }

  // 閉じるボタンなどから呼ばれる
  //
  // フォームを初期化してからモーダルを閉じる
  close() {
    this.resetAndClose();
  }

  // モーダルの背景部分をクリックしたときだけ閉じる
  //
  // フォーム本体やボタンをクリックした場合は、
  // event.target と event.currentTarget が異なるため閉じない
  closeWhenBackgroundClicked(event) {
    if (event.target === event.currentTarget) {
      this.close();
    }
  }

  // Turbo の turbo:submit-end イベント後に呼ばれる
  //
  // 送信が成功した場合だけフォームをリセットしてモーダルを閉じる。
  // バリデーションエラー時はモーダルを閉じず、エラー表示を残す。
  closeAfterSubmit(event) {
    if (!event.detail.success) return;

    this.resetAndClose();
  }

  // フォーム・エラー表示・モーダル表示をまとめて初期状態へ戻す
  resetAndClose() {
    // controller が form 要素についている前提
    this.element.reset();

    this.clearErrors();
    this.modalTarget.style.display = "none";
  }

  // エラー表示領域を空にする
  clearErrors() {
    // errors target が画面にないケースでは何もしない
    if (!this.hasErrorsTarget) return;

    this.errorsTarget.innerHTML = "";
  }
}
