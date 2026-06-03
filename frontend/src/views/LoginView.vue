<script setup>
import { ref } from 'vue'
import apiClient from '@/api/axios'
import { EyeIcon, EyeSlashIcon } from '@heroicons/vue/24/outline'

const emit = defineEmits(['navigate'])

const form = ref({
  email: '',
  password: '',
  rememberMe: false
})

const showPassword = ref(false)
const isLoggingIn = ref(false)
const errorMessage = ref('')

const handleLogin = async () => {
  errorMessage.value = ''
  isLoggingIn.value = true
  
  try {
    const payload = {
      email: form.value.email,
      password: form.value.password
    }
    
    const response = await apiClient.post('/Auth/login', payload)
    const result = response.data

    if (result.success) {
      const authData = result.data

      const token = authData.accessToken
      if (token) localStorage.setItem('token', token)

      const fullName = authData.fullName
      const role = authData.role
      if (fullName) localStorage.setItem('fullName', fullName)
      if (role) localStorage.setItem('role', role)

      const userObj = {
        fullName: fullName || '',
        role: role || '',
        email: authData.email || form.value.email
      }
      localStorage.setItem('user', JSON.stringify(userObj))

      if (role?.toLowerCase() === 'admin') {
        emit('navigate', 'dashboard')
      } else {
        emit('navigate', 'home')
      }
    } else {
      errorMessage.value = result.message || 'Đăng nhập thất bại'
    }
  } catch (error) {
    if (error.response?.data?.message) {
      errorMessage.value = error.response.data.message
    } else {
      errorMessage.value = 'Lỗi hệ thống. Vui lòng kiểm tra kết nối.'
    }
  } finally {
    isLoggingIn.value = false
  }
}
</script>

<template>
  <div class="d-flex min-vh-100" style="background-color: #f8faf5;">
    <!-- Right Side: Login Form -->
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
          <h2 class="fw-bold fs-4 text-dark mb-1">Đăng nhập</h2>
          <p class="text-muted small mb-0">Vui lòng nhập thông tin tài khoản của bạn.</p>
        </div>

        <!-- Error Alert -->
        <div v-if="errorMessage" class="alert alert-danger d-flex align-items-start gap-2 py-2 rounded-xl mb-4" role="alert">
          <svg class="flex-shrink-0 mt-1" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
          </svg>
          <span class="small fw-medium">{{ errorMessage }}</span>
        </div>

        <form @submit.prevent="handleLogin">
          <!-- Email -->
          <div class="mb-3">
            <label for="email" class="form-label small fw-semibold">Email</label>
            <input
              type="text"
              id="email"
              v-model="form.email"
              required
              class="form-control rounded-xl bg-light"
              placeholder="Nhập email"
            />
          </div>

          <!-- Password -->
          <div class="mb-3">
            <label for="password" class="form-label small fw-semibold">Mật khẩu</label>
            <div class="input-group">
              <input
                :type="showPassword ? 'text' : 'password'"
                id="password"
                v-model="form.password"
                required
                class="form-control rounded-start-xl bg-light"
                placeholder="••••••••"
              />
              <button
                type="button"
                class="btn btn-outline-secondary rounded-end-xl border-start-0"
                @click="showPassword = !showPassword"
                style="border-color:#dee2e6;"
              >
                <EyeSlashIcon v-if="!showPassword" style="width:18px;height:18px;" />
                <EyeIcon v-else style="width:18px;height:18px;" />
              </button>
            </div>
          </div>

          <!-- Remember Me & Forgot Password -->
          <div class="d-flex align-items-center justify-content-between mb-4">
            <div class="form-check">
              <input
                class="form-check-input"
                type="checkbox"
                id="remember-me"
                v-model="form.rememberMe"
              />
              <label class="form-check-label small" for="remember-me">Ghi nhớ đăng nhập</label>
            </div>
            <a href="#" class="small text-success text-decoration-none fw-medium">Quên mật khẩu?</a>
          </div>

          <!-- Submit -->
          <button
            type="submit"
            :disabled="isLoggingIn"
            class="btn btn-success w-100 rounded-xl py-2 fw-semibold d-flex align-items-center justify-content-center gap-2"
          >
            <span v-if="isLoggingIn" class="spinner-border spinner-border-sm" role="status"></span>
            {{ isLoggingIn ? 'Đang đăng nhập...' : 'Đăng nhập' }}
          </button>
        </form>

        <p class="text-center small text-muted mt-4 mb-0">
          Chưa có tài khoản?
          <button @click="emit('navigate', 'register')" class="btn btn-link text-success fw-semibold p-0 text-decoration-none">
            Đăng ký ngay
          </button>
        </p>
      </div>
    </div>
  </div>
</template>
