import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="geolocation"
export default class extends Controller {
  static targets = ["position", "status", "latitude", "longitude"];

  success(position) {
    const latitude = position.coords.latitude;
    const longitude = position.coords.longitude;
    console.log(position);

    this.statusTarget.textContent = "";
    this.positionTarget.textContent = `緯度: ${latitude}°、経度: ${longitude}°`;
    this.latitudeTarget.value = latitude;
    this.longitudeTarget.value = longitude;
  }

  // 失敗した時の処理
  // エラーメッセージを返す
  error(err) {
    console.warn(`ERROR(${err.code}): ${err.message}`);
    this.statusTarget.textContent = "位置情報取得できませんでした";
  }

  // ボタンを押した時の処理
  fetchPosition() {
    if (!navigator.geolocation) {
      this.statusTarget.textContent =
        "このブラウザーは位置情報に対応していません";
    } else {
      this.statusTarget.textContent = "位置情報を取得中…";
      navigator.geolocation.getCurrentPosition(
        (position) => this.success(position),
        (error) => this.error(error),
      );
    }
  }
}
