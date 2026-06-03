<script setup>
import { ref } from 'vue'
import apiClient from '@/api/axios'
import { toast } from '@/utils/toast'
import { EyeIcon, EyeSlashIcon } from '@heroicons/vue/24/outline'

const emit = defineEmits(['navigate'])

const form = ref({
  fullName: '',
  email: '',
  phoneNumber: '',
  password: '',
  agreeToTerms: false
})

const showPassword = ref(false)
const isRegistering = ref(false)
const errorMessage = ref('')

const handleRegister = async () => {
  errorMessage.value = ''
  
  const phone = form.value.phoneNumber.trim()
  if (!/^0\d{9}$/.test(phone)) {
    errorMessage.value = 'Số điện thoại phải có đúng 10 số và bắt đầu bằng số 0.'
    toast.error('Số điện thoại phải có đúng 10 số và bắt đầu bằng số 0.')
    return
  }

  if (form.value.password.length < 8) {
    errorMessage.value = 'Mật khẩu phải có ít nhất 8 ký tự.'
    toast.error('Mật khẩu phải có ít nhất 8 ký tự.')
    return
  }

  isRegistering.value = true
  
  try {
    const payload = {
      fullName: form.value.fullName,
      email: form.value.email,
      phoneNumber: form.value.phoneNumber,
      password: form.value.password
    }
    
    const response = await apiClient.post('/Auth/register', payload)
    toast.success(response.data.message || 'Đăng ký tài khoản thành công!')
    emit('navigate', 'login')
  } catch (error) {
    if (error.response && error.response.data) {
      if (error.response.data.errors) {
        const errors = error.response.data.errors
        const firstErrorKey = Object.keys(errors)[0]
        errorMessage.value = errors[firstErrorKey][0]
      } else if (error.response.data.message) {
        errorMessage.value = error.response.data.message
      } else {
        errorMessage.value = 'Lỗi dữ liệu từ hệ thống.'
      }
    } else {
      errorMessage.value = 'Lỗi hệ thống. Vui lòng thử lại sau.'
    }
    toast.error(errorMessage.value)
  } finally {
    isRegistering.value = false
  }
}
</script>

<template>
  <div class="d-flex min-vh-100" style="background-color: #f8faf5;">
    <!-- Right Side: Register Form -->
    <div class="flex-grow-1 d-flex align-items-center justify-content-center p-4 position-relative">
      <!-- Back to Home -->
      <button
        @click="emit('navigate', 'home')"
        class="btn btn-link text-muted position-absolute top-0 start-0 mt-3 ms-3 d-flex align-items-center gap-2 text-decoration-none"
        style="font-size:0.8rem;"
      >
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 20 20" fill="currentColor">
          <path fill-rule="evenodd" d="M9.707 16.707a1 1 0 01-1.414 0l-6-6a1 1 0 010-1.414l6-6a1 1 0 011.414 1.414L5.414 9H17a1 1 0 110 2H5.414l4.293 4.293a1 1 0 010 1.414z" clip-rule="evenodd" />
        </svg>
        Trang chủ
      </button>

      <div class="bg-white p-4 p-sm-5 border shadow-sm" style="width:100%; max-width:28rem; border-radius: 12px; border-color: #e5e7eb;">
        <div class="mb-4">
          <h2 class="fw-bold fs-4 text-dark mb-1">Tạo tài khoản</h2>
          <p class="text-muted small mb-0">Bắt đầu hành trình sống khỏe cùng FreshFarm.</p>
        </div>

        <!-- Error Alert -->
        <div v-if="errorMessage" class="alert alert-danger d-flex align-items-start gap-2 py-2 rounded-xl mb-4" role="alert">
          <svg class="flex-shrink-0 mt-1" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
          </svg>
          <span class="small fw-medium">{{ errorMessage }}</span>
        </div>

        <form @submit.prevent="handleRegister">
          <!-- Full Name -->
          <div class="mb-3">
            <label for="fullName" class="form-label small fw-semibold">Họ và tên</label>
            <input type="text" id="fullName" v-model="form.fullName" required
              class="form-control rounded-xl bg-light" placeholder="Nhập họ và tên của bạn" />
          </div>

          <!-- Email -->
          <div class="mb-3">
            <label for="email" class="form-label small fw-semibold">Email</label>
            <input type="email" id="email" v-model="form.email" required
              class="form-control rounded-xl bg-light" placeholder="Nhập địa chỉ email" />
          </div>

          <!-- Phone -->
          <div class="mb-3">
            <label for="phoneNumber" class="form-label small fw-semibold">Số điện thoại</label>
            <input type="text" id="phoneNumber" v-model="form.phoneNumber" required
              maxlength="10"
              class="form-control rounded-xl bg-light" placeholder="Nhập số điện thoại" />
          </div>

          <!-- Password -->
          <div class="mb-3">
            <label for="password" class="form-label small fw-semibold">Mật khẩu</label>
            <div class="input-group">
              <input :type="showPassword ? 'text' : 'password'" id="password" v-model="form.password" required
                class="form-control rounded-start-xl bg-light" placeholder="••••••••" />
              <button type="button" class="btn btn-outline-secondary rounded-end-xl border-start-0"
                @click="showPassword = !showPassword" style="border-color:#dee2e6;">
                <EyeSlashIcon v-if="!showPassword" style="width:18px;height:18px;" />
                <EyeIcon v-else style="width:18px;height:18px;" />
              </button>
            </div>
          </div>

          <!-- Terms -->
          <div class="form-check mb-4">
            <input class="form-check-input" type="checkbox" id="terms" v-model="form.agreeToTerms" required />
            <label class="form-check-label small text-muted" for="terms">
              Tôi đồng ý với các
              <a href="#" class="text-success text-decoration-none fw-medium">Điều khoản dịch vụ</a>
              và
              <a href="#" class="text-success text-decoration-none fw-medium">Chính sách bảo mật</a>.
            </label>
          </div>

          <!-- Submit -->
          <button type="submit" :disabled="isRegistering"
            class="btn btn-success w-100 rounded-xl py-2 fw-semibold d-flex align-items-center justify-content-center gap-2">
            <span v-if="isRegistering" class="spinner-border spinner-border-sm" role="status"></span>
            {{ isRegistering ? 'Đang tạo tài khoản...' : 'Đăng ký ngay' }}
          </button>
        </form>

        <p class="text-center small text-muted mt-4 mb-0">
          Đã có tài khoản?
          <button @click="emit('navigate', 'login')" class="btn btn-link text-success fw-semibold p-0 text-decoration-none">
            Đăng nhập ngay
          </button>
        </p>
      </div>
    </div>
  </div>
</template>
