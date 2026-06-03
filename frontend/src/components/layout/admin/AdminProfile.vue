<script setup>
import { ref, computed, onMounted } from 'vue'
import { CheckIcon, EyeIcon, EyeSlashIcon } from '@heroicons/vue/24/outline'
import apiClient from '@/api/axios'
import { toast } from '@/utils/toast'

const form = ref({ fullName: '', email: '', phoneNumber: '' })
const passwordForm = ref({ currentPassword: '', newPassword: '', confirmPassword: '' })
const activeTab = ref('info')
const saving = ref(false)
const savedSuccess = ref(false)
const showCurrentPw = ref(false)
const showNewPw = ref(false)
const passwordError = ref('')
const passwordSuccess = ref(false)

const loadUser = async () => {
  try {
    const response = await apiClient.get('/Auth/profile')
    const user = response.data
    form.value.fullName = user.fullName || ''
    form.value.email = user.email || ''
    form.value.phoneNumber = user.phoneNumber || user.phone || ''
  } catch (e) {
    const data = localStorage.getItem('user')
    const user = data ? JSON.parse(data) : {}
    form.value.fullName = user.fullName || ''
    form.value.email = user.email || ''
    form.value.phoneNumber = user.phoneNumber || user.phone || ''
    console.warn('Không thể tải profile từ API, sử dụng fallback LocalStorage:', e.message)
  }
}

const userInitials = computed(() => {
  const name = form.value.fullName || 'Admin'
  const parts = name.trim().split(/\s+/)
  if (parts.length >= 2) return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase()
  return name.substring(0, 2).toUpperCase()
})

const saveProfile = async () => {
  const phone = form.value.phoneNumber.trim()
  if (!/^0\d+$/.test(phone)) {
    toast.error('Số điện thoại bắt buộc là số và bắt đầu là số 0.')
    return
  }

  saving.value = true
  savedSuccess.value = false
  try {
    const data = localStorage.getItem('user')
    const user = data ? JSON.parse(data) : {}

    await apiClient.put('/Auth/profile', {
      userId: user.userId || user.id,
      fullName: form.value.fullName,
      email: form.value.email,
      phoneNumber: form.value.phoneNumber
    })

    user.fullName = form.value.fullName
    user.email = form.value.email
    user.phoneNumber = form.value.phoneNumber
    user.phone = form.value.phoneNumber
    localStorage.setItem('user', JSON.stringify(user))
    localStorage.setItem('fullName', form.value.fullName)
    window.dispatchEvent(new Event('storage'))
    
    savedSuccess.value = true
    toast.success('Cập nhật thông tin cá nhân thành công!')
    setTimeout(() => savedSuccess.value = false, 3000)
  } catch (e) {
    toast.error('Cập nhật thất bại: ' + (e.response?.data?.message || e.message))
  } finally {
    saving.value = false
  }
}

const changePassword = async () => {
  passwordError.value = ''
  passwordSuccess.value = false
  if (!passwordForm.value.currentPassword || !passwordForm.value.newPassword) {
    passwordError.value = 'Vui lòng điền đầy đủ thông tin.'
    return
  }
  if (passwordForm.value.newPassword.length < 6) {
    passwordError.value = 'Mật khẩu mới phải có ít nhất 6 ký tự.'
    return
  }
  if (passwordForm.value.newPassword !== passwordForm.value.confirmPassword) {
    passwordError.value = 'Mật khẩu xác nhận không khớp.'
    return
  }
  saving.value = true
  try {
    await apiClient.post('/Auth/change-password', {
      currentPassword: passwordForm.value.currentPassword,
      newPassword: passwordForm.value.newPassword
    })
    passwordSuccess.value = true
    toast.success('Đổi mật khẩu thành công!')
    passwordForm.value = { currentPassword: '', newPassword: '', confirmPassword: '' }
    setTimeout(() => passwordSuccess.value = false, 3000)
  } catch (e) {
    passwordError.value = e.response?.data?.message || 'Không thể đổi mật khẩu. Vui lòng kiểm tra mật khẩu hiện tại.'
    toast.error('Lỗi: ' + passwordError.value)
  } finally {
    saving.value = false
  }
}

onMounted(() => { loadUser() })
</script>

<template>
  <div class="container-fluid py-4" style="max-width:56rem; ">
    <h1 class="fs-5 fw-bold text-dark mb-1">Hồ sơ quản trị viên</h1>
    <p class="small text-muted mb-4">Quản lý thông tin cá nhân và bảo mật tài khoản admin</p>

    <div class="row g-4">
      <!-- Left: Avatar Card -->
      <div class="col-12 col-lg-3">
        <div class="bg-white rounded-2xl border shadow-sm p-4 text-center" style="border-color:#f3f4f6;">
          <div class="d-flex align-items-center justify-content-center rounded-circle bg-success text-white fw-bold mx-auto shadow"
            style="width:80px;height:80px;font-size:1.75rem;">
            {{ userInitials }}
          </div>
          <h2 class="mt-3 fw-bold text-dark truncate small">{{ form.fullName || 'Admin' }}</h2>
          <p class="text-muted truncate" style="font-size:0.7rem;">{{ form.email }}</p>
          <span class="badge rounded-pill bg-success bg-opacity-10 text-success border mt-1" style="font-size:0.6rem;border-color:#bbf7d0!important;">
            QUẢN TRỊ HỆ THỐNG
          </span>

          <div class="mt-4 d-flex flex-column gap-1">
            <button @click="activeTab = 'info'"
              class="btn btn-sm text-start rounded-xl fw-medium"
              :class="activeTab === 'info' ? 'btn-success bg-opacity-10 text-success' : 'btn-light text-muted'">
              Thông tin cá nhân
            </button>
            <button @click="activeTab = 'password'"
              class="btn btn-sm text-start rounded-xl fw-medium"
              :class="activeTab === 'password' ? 'btn-success bg-opacity-10 text-success' : 'btn-light text-muted'">
              Đổi mật khẩu
            </button>
          </div>
        </div>
      </div>

      <!-- Right: Content -->
      <div class="col-12 col-lg-9">
        
        <div v-if="activeTab === 'info'" class="bg-white rounded-2xl border shadow-sm p-4" style="border-color:#f3f4f6;">
          <h3 class="fw-bold text-dark small mb-4">Thông tin cá nhân</h3>

          <div v-if="savedSuccess" class="alert alert-success d-flex align-items-center gap-2 py-2 rounded-xl mb-3">
            <CheckIcon style="width:16px;height:16px;flex-shrink:0;" />
            <span class="small fw-medium">Cập nhật thông tin thành công!</span>
          </div>

          <form @submit.prevent="saveProfile">
            <div class="row g-3 mb-3">
              <div class="col-12 col-sm-6">
                <label class="form-label small fw-semibold">Họ và tên</label>
                <input v-model="form.fullName" type="text" required class="form-control rounded-xl bg-white border" />
              </div>
              <div class="col-12 col-sm-6">
                <label class="form-label small fw-semibold">Email</label>
                <input v-model="form.email" type="email" required class="form-control rounded-xl bg-white border" />
              </div>
            </div>
            <div class="row g-3 mb-4">
              <div class="col-12 col-sm-6">
                <label class="form-label small fw-semibold">Số điện thoại</label>
                <input v-model="form.phoneNumber" type="tel" class="form-control rounded-xl bg-white border" />
              </div>
            </div>
            <div class="d-flex justify-content-end">
              <button type="submit" :disabled="saving" class="btn btn-success rounded-xl fw-semibold px-4">
                <span v-if="saving" class="spinner-border spinner-border-sm me-1"></span>
                {{ saving ? 'Đang lưu...' : 'Lưu' }}
              </button>
            </div>
          </form>
        </div>

        <!-- Tab: Change Password -->
        <div v-if="activeTab === 'password'" class="bg-white rounded-2xl border shadow-sm p-4" style="border-color:#f3f4f6;">
          <h3 class="fw-bold text-dark small mb-4">Đổi mật khẩu</h3>

          <div v-if="passwordError" class="alert alert-danger py-2 rounded-xl small fw-medium mb-3">{{ passwordError }}</div>
          <div v-if="passwordSuccess" class="alert alert-success d-flex align-items-center gap-2 py-2 rounded-xl mb-3">
            <CheckIcon style="width:16px;height:16px;flex-shrink:0;" />
            <span class="small fw-medium">Đổi mật khẩu thành công!</span>
          </div>

          <form @submit.prevent="changePassword" style="max-width:28rem;">
            <div class="mb-3">
              <label class="form-label small fw-semibold">Mật khẩu hiện tại</label>
              <div class="input-group">
                <input v-model="passwordForm.currentPassword" :type="showCurrentPw ? 'text' : 'password'" required
                  class="form-control rounded-start-xl bg-white border" placeholder="••••••••" />
                <button type="button" @click="showCurrentPw = !showCurrentPw"
                  class="btn btn-outline-secondary rounded-end-xl border-start-0" style="border-color:#dee2e6;">
                  <EyeIcon v-if="!showCurrentPw" style="width:16px;height:16px;" />
                  <EyeSlashIcon v-else style="width:16px;height:16px;" />
                </button>
              </div>
            </div>
            <div class="mb-3">
              <label class="form-label small fw-semibold">Mật khẩu mới</label>
              <div class="input-group">
                <input v-model="passwordForm.newPassword" :type="showNewPw ? 'text' : 'password'" required
                  class="form-control rounded-start-xl bg-white border" placeholder="Ít nhất 6 ký tự" />
                <button type="button" @click="showNewPw = !showNewPw"
                  class="btn btn-outline-secondary rounded-end-xl border-start-0" style="border-color:#dee2e6;">
                  <EyeIcon v-if="!showNewPw" style="width:16px;height:16px;" />
                  <EyeSlashIcon v-else style="width:16px;height:16px;" />
                </button>
              </div>
            </div>
            <div class="mb-4">
              <label class="form-label small fw-semibold">Xác nhận mật khẩu mới</label>
              <input v-model="passwordForm.confirmPassword" type="password" required
                class="form-control rounded-xl bg-white border" placeholder="••••••••" />
            </div>
            <button type="submit" :disabled="saving" class="btn btn-success rounded-xl fw-semibold px-4">
              <span v-if="saving" class="spinner-border spinner-border-sm me-1"></span>
              {{ saving ? 'Đang xử lý...' : 'Lưu' }}
            </button>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>
