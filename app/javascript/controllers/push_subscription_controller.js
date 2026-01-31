// Web Push Subscription Manager
// Handles Service Worker registration and push subscription

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "status"]
  static values = {
    subscribed: Boolean
  }

  connect() {
    this.checkSupport()
    this.updateUI()
  }

  checkSupport() {
    if (!('serviceWorker' in navigator)) {
      console.warn('[WebPush] Service Workers not supported')
      this.disable('Trình duyệt không hỗ trợ')
      return false
    }

    if (!('PushManager' in window)) {
      console.warn('[WebPush] Push notifications not supported')
      this.disable('Thông báo đẩy không được hỗ trợ')
      return false
    }

    return true
  }

  async updateUI() {
    if (!this.checkSupport()) return

    const registration = await navigator.serviceWorker.getRegistration()
    if (!registration) {
      this.subscribedValue = false
      return
    }

    const subscription = await registration.pushManager.getSubscription()
    this.subscribedValue = !!subscription
  }

  subscribedValueChanged() {
    if (this.hasButtonTarget) {
      if (this.subscribedValue) {
        this.buttonTarget.textContent = '🔔 Đã bật thông báo'
        this.buttonTarget.classList.remove('bg-brand-primary')
        this.buttonTarget.classList.add('bg-gray-600')
      } else {
        this.buttonTarget.textContent = '🔕 Bật thông báo'
        this.buttonTarget.classList.remove('bg-gray-600')
        this.buttonTarget.classList.add('bg-brand-primary')
      }
    }
  }

  disable(message) {
    if (this.hasButtonTarget) {
      this.buttonTarget.disabled = true
      this.buttonTarget.textContent = message
      this.buttonTarget.classList.add('opacity-50', 'cursor-not-allowed')
    }
  }

  async toggle() {
    if (this.subscribedValue) {
      await this.unsubscribe()
    } else {
      await this.subscribe()
    }
  }

  async subscribe() {
    try {
      // 1. Register Service Worker
      const registration = await navigator.serviceWorker.register('/service-worker.js')
      console.log('[WebPush] Service Worker registered')

      // 2. Request notification permission
      const permission = await Notification.requestPermission()
      if (permission !== 'granted') {
        console.warn('[WebPush] Notification permission denied')
        this.showStatus('Bạn đã từ chối quyền thông báo', 'error')
        return
      }

      // 3. Get VAPID public key from server
      const keyResponse = await fetch('/push_subscriptions/vapid_public_key')
      const keyData = await keyResponse.json()
      const vapidPublicKey = keyData.vapid_public_key

      // 4. Subscribe to push service
      const subscription = await registration.pushManager.subscribe({
        userVisibleOnly: true,
        applicationServerKey: this.urlBase64ToUint8Array(vapidPublicKey)
      })

      // 5. Send subscription to server
      const response = await fetch('/push_subscriptions', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({
          subscription: {
            endpoint: subscription.endpoint,
            p256dh: btoa(String.fromCharCode.apply(null, new Uint8Array(subscription.getKey('p256dh')))),
            auth: btoa(String.fromCharCode.apply(null, new Uint8Array(subscription.getKey('auth'))))
          }
        })
      })

      if (response.ok) {
        this.subscribedValue = true
        this.showStatus('Đã bật thông báo', 'success')
        console.log('[WebPush] Subscribed successfully')
      } else {
        throw new Error('Server rejected subscription')
      }

    } catch (error) {
      console.error('[WebPush] Subscribe error:', error)
      this.showStatus('Không thể bật thông báo', 'error')
    }
  }

  async unsubscribe() {
    try {
      const registration = await navigator.serviceWorker.getRegistration()
      if (!registration) return

      const subscription = await registration.pushManager.getSubscription()
      if (!subscription) return

      // Unsubscribe from push service
      await subscription.unsubscribe()

      // Remove from server
      await fetch('/push_subscriptions?endpoint=' + encodeURIComponent(subscription.endpoint), {
        method: 'DELETE',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        }
      })

      this.subscribedValue = false
      this.showStatus('Đã tắt thông báo', 'success')
      console.log('[WebPush] Unsubscribed successfully')

    } catch (error) {
      console.error('[WebPush] Unsubscribe error:', error)
      this.showStatus('Không thể tắt thông báo', 'error')
    }
  }

  showStatus(message, type) {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = message
      this.statusTarget.classList.toggle('text-green-600', type === 'success')
      this.statusTarget.classList.toggle('text-red-600', type === 'error')
      this.statusTarget.classList.remove('hidden')

      setTimeout(() => {
        this.statusTarget.classList.add('hidden')
      }, 3000)
    }
  }

  // Convert base64 VAPID key to Uint8Array
  urlBase64ToUint8Array(base64String) {
    const padding = '='.repeat((4 - base64String.length % 4) % 4)
    const base64 = (base64String + padding).replace(/-/g, '+').replace(/_/g, '/')
    const rawData = window.atob(base64)
    const outputArray = new Uint8Array(rawData.length)

    for (let i = 0; i < rawData.length; ++i) {
      outputArray[i] = rawData.charCodeAt(i)
    }
    return outputArray
  }
}
