<template>
  <div class="bg-success text-white rounded-3 p-4">
    <div class="d-flex align-items-center justify-content-between mb-3">
      <h3 class="small fw-semibold mb-0">Thông báo</h3>
      <span class="badge bg-danger small">MỚI</span>
    </div>

    <div
      v-for="(n, i) in notifications"
      :key="i"
      class="d-flex gap-2 py-2"
      :class="i < notifications.length - 1 ? 'border-bottom border-opacity-25 border-white' : ''"
    >
      <div class="pt-1 flex-shrink-0">
        <div class="rounded-circle" style="width: 0.5rem; height: 0.5rem;" :class="dotColor(n.color)"></div>
      </div>
      <div>
        <p class="small mb-1" style="color: rgba(255,255,255,0.9);">{{ n.text }}</p>
        <p class="mb-0" style="font-size: 0.6875rem; color: rgba(255,255,255,0.4);">{{ n.time }}</p>
      </div>
    </div>

    <button class="btn btn-light w-100 mt-3 py-2 small fw-medium">
      TẤT CẢ THÔNG BÁO
    </button>
  </div>
</template>

<script setup>
const notifications = [
  { color: 'green',  text: 'Thay đổi bảng giá: Cà chua bí hữu cơ (+5%)', time: '2 giờ trước' },
  { color: 'orange', text: 'Nhập kho: 200kg Xà lách thủy canh từ trang trại Đà Lạt', time: '5 giờ trước' },
  { color: 'red',    text: 'Khách hàng Minh Ánh đã đặt đơn #FF-8495', time: '1 ngày trước' },
]

function dotColor(color) {
  const map = {
    green:  'bg-green-300',
    orange: 'bg-yellow-300',
    red:    'bg-red-300',
  }
  return map[color] ?? 'bg-white'
}
</script>
