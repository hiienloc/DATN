import { reactive } from 'vue'

export const toasts = reactive([])

export const toast = {
  add(message, type = 'success', duration = 3500) {
    const id = Date.now() + Math.random()
    
    // Đảm bảo số lượng toast hiển thị cùng lúc tối đa là 5 để không vỡ khung
    if (toasts.length >= 5) {
      toasts.shift()
    }
    
    toasts.push({ id, message, type })
    setTimeout(() => {
      this.remove(id)
    }, duration)
  },
  
  remove(id) {
    const idx = toasts.findIndex(t => t.id === id)
    if (idx !== -1) {
      toasts.splice(idx, 1)
    }
  },
  
  success(msg) { this.add(msg, 'success') },
  error(msg) { this.add(msg, 'danger') }, // Dùng Danger thay Error vì Bootstrap dùng class 'bg-danger'
  warning(msg) { this.add(msg, 'warning') },
  info(msg) { this.add(msg, 'info') }
}
