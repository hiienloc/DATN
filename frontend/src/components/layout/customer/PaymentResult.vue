<template>
  <div class="min-vh-100 d-flex align-items-center justify-content-center py-5 px-3" style="background:#f8faf5; ">
    <div class="bg-white rounded-4 border shadow-lg overflow-hidden w-100 position-relative animate-fade-up" style="max-width: 520px;">
      <!-- Decorative Top Bar -->
      <div :class="status === 'success' ? 'bg-success' : 'bg-danger'" style="height: 6px;"></div>
      
      <div class="p-5 text-center">
        <!-- Icon -->
        <div class="d-flex justify-content-center mb-4">
          <div 
            class="rounded-circle d-flex align-items-center justify-content-center animate-scale-in"
            :class="status === 'success' ? 'bg-success bg-opacity-10 text-success' : 'bg-danger bg-opacity-10 text-danger'"
            style="width: 80px; height: 80px;"
          >
            <CheckCircleIcon v-if="status === 'success'" style="width: 48px; height: 48px;" />
            <XCircleIcon v-else style="width: 48px; height: 48px;" />
          </div>
        </div>

        <!-- Content -->
        <h1 class="fw-extrabold text-dark fs-4 mb-2">
          {{ status === 'success' ? 'Thanh toán thành công!' : 'Thanh toán thất bại' }}
        </h1>
        <p class="text-muted small mb-4">
          {{ status === 'success' 
            ? 'Đơn hàng của bạn đã được thanh toán thành công và đang chờ hệ thống xác nhận.' 
            : 'Giao dịch thanh toán qua VNPay không thành công hoặc đã bị hủy. Vui lòng kiểm tra lại!' }}
        </p>

        <!-- Info Card -->
        <div class="bg-light rounded-3 p-3 mb-4 text-start border" style="font-size: 0.85rem;">
          <div class="d-flex justify-content-between mb-2">
            <span class="text-muted">Mã giao dịch/đơn hàng:</span>
            <span class="fw-bold text-dark">#{{ orderId || 'N/A' }}</span>
          </div>
          <div class="d-flex justify-content-between mb-2">
            <span class="text-muted">Trạng thái thanh toán:</span>
            <span :class="status === 'success' ? 'text-success fw-bold' : 'text-danger fw-bold'">
              {{ status === 'success' ? 'Đã thanh toán' : 'Thất bại / Đã hủy' }}
            </span>
          </div>
          <div class="d-flex justify-content-between">
            <span class="text-muted">Phương thức:</span>
            <span class="fw-semibold text-dark">VNPay Online</span>
          </div>
        </div>

        <!-- Actions -->
        <div class="d-flex flex-column gap-2 mt-4">
          <button 
            @click="$emit('navigate', 'orderHistory')" 
            class="btn btn-success rounded-pill fw-bold py-2 shadow-sm d-flex align-items-center justify-content-center gap-2"
          >
            Xem lịch sử đơn hàng
            <ArrowRightIcon style="width:16px;height:16px;" />
          </button>
          <button 
            @click="$emit('navigate', 'home')" 
            class="btn btn-light border rounded-pill fw-semibold py-2 text-muted"
          >
            Quay lại trang chủ
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { CheckCircleIcon, XCircleIcon, ArrowRightIcon } from '@heroicons/vue/24/outline'

defineProps({
  status: {
    type: String,
    required: true // 'success' | 'failed'
  },
  orderId: {
    type: String,
    default: ''
  }
})

defineEmits(['navigate'])
</script>

<style scoped>
.animate-fade-up {
  animation: fadeUp 0.5s cubic-bezier(0.16, 1, 0.3, 1) forwards;
}
.animate-scale-in {
  animation: scaleIn 0.5s cubic-bezier(0.34, 1.56, 0.64, 1) forwards;
}
@keyframes fadeUp {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}
@keyframes scaleIn {
  from { opacity: 0; transform: scale(0.5); }
  to { opacity: 1; transform: scale(1); }
}
</style>
