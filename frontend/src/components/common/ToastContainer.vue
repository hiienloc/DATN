<template>
  <Teleport to="body">
    <div class="toast-container position-fixed top-0 end-0 p-4" style="z-index: 999999; ">
      <TransitionGroup name="toast-fade-slide">
        <div
          v-for="t in toasts"
          :key="t.id"
          class="custom-toast d-flex align-items-center px-4 py-3 mb-3 text-dark position-relative"
          :class="`bg-toast-${t.type}`"
          role="alert"
          aria-live="assertive"
          aria-atomic="true"
        >
          <!-- Modern SVG Icons based on Type -->
          <div class="me-3 flex-shrink-0 d-flex align-items-center justify-content-center">
            <!-- Success Icon -->
            <svg v-if="t.type === 'success'" class="toast-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24" style="width: 20px; height: 20px;">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            <!-- Danger Icon -->
            <svg v-else-if="t.type === 'danger'" class="toast-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24" style="width: 20px; height: 20px;">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            <!-- Warning Icon -->
            <svg v-else-if="t.type === 'warning'" class="toast-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24" style="width: 20px; height: 20px;">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
            </svg>
            <!-- Info Icon -->
            <svg v-else class="toast-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24" style="width: 20px; height: 20px;">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          </div>
          
          <!-- Message Content -->
          <div class="toast-content flex-grow-1 small fw-bold pe-3" style="letter-spacing: 0.1px; line-height: 1.4;">
            {{ t.message }}
          </div>
          
          <!-- Custom Close Button -->
          <button 
            type="button" 
            class="btn-close-custom flex-shrink-0 ms-auto" 
            @click="removeToast(t.id)"
            aria-label="Đóng"
          >
            <svg width="12" height="12" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="3">
              <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"/>
            </svg>
          </button>
          
          <!-- Smooth horizontal progress bar -->
          <div class="toast-progress" :class="`progress-${t.type}`"></div>
        </div>
      </TransitionGroup>
    </div>
  </Teleport>
</template>

<script setup>
import { toasts, toast } from '@/utils/toast'

const removeToast = (id) => {
  toast.remove(id)
}
</script>

<style scoped>
.custom-toast {
  min-width: 320px;
  max-width: 420px;
  border-radius: 12px !important;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.05);
  overflow: hidden;
  transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
  border: 1px solid rgba(0, 0, 0, 0.03) !important;
}

/* Success - Pastel Mint Green */
.bg-toast-success {
  background: #ebf7f3 !important;
  border-left: 5px solid #359379 !important;
  box-shadow: 0 10px 30px rgba(53, 147, 121, 0.12) !important;
}
.bg-toast-success .toast-content {
  color: #1d5745 !important;
}
.bg-toast-success .toast-icon {
  color: #359379 !important;
}
.bg-toast-success .btn-close-custom {
  color: #1d5745;
}

/* Danger - Pastel Red */
.bg-toast-danger {
  background: #fde8e8 !important;
  border-left: 5px solid #ef4444 !important;
  box-shadow: 0 10px 30px rgba(239, 68, 68, 0.12) !important;
}
.bg-toast-danger .toast-content {
  color: #991b1b !important;
}
.bg-toast-danger .toast-icon {
  color: #ef4444 !important;
}
.bg-toast-danger .btn-close-custom {
  color: #991b1b;
}

/* Warning - Pastel Yellow */
.bg-toast-warning {
  background: #fffbeb !important;
  border-left: 5px solid #f59e0b !important;
  box-shadow: 0 10px 30px rgba(245, 158, 11, 0.12) !important;
}
.bg-toast-warning .toast-content {
  color: #92400e !important;
}
.bg-toast-warning .toast-icon {
  color: #f59e0b !important;
}
.bg-toast-warning .btn-close-custom {
  color: #92400e;
}

/* Info - Pastel Blue */
.bg-toast-info {
  background: #f0f9ff !important;
  border-left: 5px solid #0ea5e9 !important;
  box-shadow: 0 10px 30px rgba(14, 165, 233, 0.12) !important;
}
.bg-toast-info .toast-content {
  color: #075985 !important;
}
.bg-toast-info .toast-icon {
  color: #0ea5e9 !important;
}
.bg-toast-info .btn-close-custom {
  color: #075985;
}

/* Custom Close Button */
.btn-close-custom {
  background: none;
  border: none;
  padding: 4px;
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0.6;
  transition: opacity 0.2s, transform 0.2s;
  cursor: pointer;
  border-radius: 6px !important;
}
.btn-close-custom:hover {
  opacity: 1;
  background-color: rgba(0, 0, 0, 0.05);
}

/* Transition Group Animations */
.toast-fade-slide-enter-from {
  opacity: 0;
  transform: translate3d(50px, 0, 0) scale(0.85);
}

.toast-fade-slide-leave-to {
  opacity: 0;
  transform: translate3d(20px, -30px, 0) scale(0.9);
}

.toast-fade-slide-leave-active {
  position: absolute;
}

/* Progress bar animation */
.toast-progress {
  position: absolute;
  bottom: 0;
  left: 0;
  height: 3.5px;
  width: 100%;
  animation: shrinkWidth 3.5s linear forwards;
}

.progress-success { background: #359379 !important; }
.progress-danger  { background: #ef4444 !important; }
.progress-warning { background: #f59e0b !important; }
.progress-info    { background: #0ea5e9 !important; }

@keyframes shrinkWidth {
  from { width: 100%; }
  to { width: 0%; }
}
</style>
