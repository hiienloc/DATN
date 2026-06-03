<script setup>
import { ref, computed, onMounted } from 'vue'
import { CheckIcon, EyeIcon, EyeSlashIcon } from '@heroicons/vue/24/outline'
import apiClient from '@/api/axios'
import { toast } from '@/utils/toast'

const emit = defineEmits(['navigate'])

const form = ref({
  fullName: '',
  email: '',
  phoneNumber: '',
  address: ''
})

const loadUserFromApi = async () => {
  try {
    const response = await apiClient.get('/Auth/profile')
    const user = response.data
    form.value.fullName = user.fullName || ''
    form.value.email = user.email || ''
    form.value.phoneNumber = user.phoneNumber || user.phone || ''
    
    const localUser = JSON.parse(localStorage.getItem('user') || '{}')
    form.value.address = localUser.address || 'Đại Học CNTT&TT'
  } catch (e) {
    const localUser = JSON.parse(localStorage.getItem('user') || '{}')
    form.value.fullName = localUser.fullName || ''
    form.value.email = localUser.email || ''
    form.value.phoneNumber = localUser.phoneNumber || localUser.phone || ''
    form.value.address = localUser.address || 'Đại Học CNTT&TT'
  }
}

const passwordForm = ref({ currentPassword: '', newPassword: '', confirmPassword: '' })

const activeTab = ref('info')
const saving = ref(false)
const savedSuccess = ref(false)
const showCurrentPw = ref(false)
const showNewPw = ref(false)
const passwordError = ref('')
const passwordSuccess = ref(false)

const userInitials = computed(() => {
  const name = form.value.fullName
  if (!name) return 'ND'
  const parts = name.trim().split(/\s+/)
  if (parts.length >= 2) return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase()
  return name.substring(0, 2).toUpperCase()
})

const saveProfile = async () => {
  // Kiểm tra tất cả trường không được để trống
  if (!form.value.fullName.trim()) {
    toast.error('Họ và tên không được để trống.')
    return
  }
  if (!form.value.email.trim()) {
    toast.error('Email không được để trống.')
    return
  }
  if (!form.value.phoneNumber.trim()) {
    toast.error('Số điện thoại không được để trống.')
    return
  }
  if (!form.value.address.trim()) {
    toast.error('Địa chỉ giao hàng không được để trống.')
    return
  }

  const phone = form.value.phoneNumber.trim()
  if (!/^0\d+$/.test(phone)) {
    toast.error('Số điện thoại bắt buộc là số và bắt đầu là số 0.')
    return
  }

  saving.value = true
  savedSuccess.value = false
  try {
    const localUser = JSON.parse(localStorage.getItem('user') || '{}')
    const userId = localUser.userId || localUser.id
    
    await apiClient.put('/Auth/profile', {
      userId: userId,
      fullName: form.value.fullName,
      email: form.value.email,
      phoneNumber: form.value.phoneNumber
    })
    
    localUser.fullName = form.value.fullName
    localUser.email = form.value.email
    localUser.phoneNumber = form.value.phoneNumber
    localUser.phone = form.value.phoneNumber
    localUser.address = form.value.address
    localStorage.setItem('user', JSON.stringify(localUser))
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
  if (passwordForm.value.newPassword.length < 8) {
    passwordError.value = 'Mật khẩu mới phải có ít nhất 8 ký tự.'
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
  } finally {
    saving.value = false
  }
}

onMounted(() => {
  loadUserFromApi()
  document.title = 'Tài khoản của tôi | FreshFarm'
})
</script>

<template>
  <div class="container-xl px-3 px-sm-4 py-5" style="max-width:56rem;">
    <h1 class="fs-5 fw-extrabold text-dark mb-1">Tài khoản của tôi</h1>
    <p class="small text-muted mb-4">Quản lý thông tin cá nhân và bảo mật tài khoản</p>

    <div class="row g-4">
      <!-- Left: Avatar Card -->
      <div class="col-12 col-lg-3">
        <div class="bg-white rounded-xl border shadow-sm p-4 text-center" style="border-color:#f3f4f6;">
          <div class="d-flex align-items-center justify-content-center rounded-circle bg-success text-white fw-bold mx-auto shadow"
            style="width:72px;height:72px;font-size:1.5rem;">
            {{ userInitials }}
          </div>
          <h2 class="mt-3 fw-bold text-dark truncate small mb-0">{{ form.fullName || 'Người dùng' }}</h2>
          <p class="text-muted truncate mb-3" style="font-size:0.65rem;">{{ form.email }}</p>

          <div class="d-flex flex-column gap-1">
            <button @click="activeTab = 'info'"
              class="btn btn-sm text-start rounded-xl fw-medium"
              :class="activeTab === 'info' ? 'btn-success bg-opacity-10 text-success' : 'btn-light text-muted'">
              👤 Thông tin cá nhân
            </button>
            <button @click="activeTab = 'password'"
              class="btn btn-sm text-start rounded-xl fw-medium"
              :class="activeTab === 'password' ? 'btn-success bg-opacity-10 text-success' : 'btn-light text-muted'">
              🔒 Đổi mật khẩu
            </button>
            <button @click="$emit('navigate', 'orderHistory')"
              class="btn btn-sm btn-light text-muted text-start rounded-xl fw-medium">
              📋 Đơn hàng của tôi
            </button>
          </div>
        </div>
      </div>

      <!-- Right: Content -->
      <div class="col-12 col-lg-9">
        <!-- Tab: Personal Info -->
        <div v-if="activeTab === 'info'" class="bg-white rounded-xl border shadow-sm p-4" style="border-color:#f3f4f6;">
          <h3 class="fw-bold text-dark small mb-4">Thông tin cá nhân</h3>

          <div v-if="savedSuccess" class="alert alert-success d-flex align-items-center gap-2 py-2 rounded-xl mb-3">
            <CheckIcon style="width:16px;height:16px;flex-shrink:0;" />
            <span class="small fw-medium">Cập nhật thông tin thành công!</span>
          </div>

          <form @submit.prevent="saveProfile">
            <div class="row g-3 mb-3">
              <div class="col-12 col-sm-6">
                <label for="pf-name" class="form-label small fw-semibold">Họ và tên</label>
                <input id="pf-name" v-model="form.fullName" type="text" required class="form-control rounded-xl bg-light" />
              </div>
              <div class="col-12 col-sm-6">
                <label for="pf-email" class="form-label small fw-semibold">Email</label>
                <input id="pf-email" v-model="form.email" type="email" required class="form-control rounded-xl bg-light" />
              </div>
            </div>
            <div class="row g-3 mb-4">
              <div class="col-12 col-sm-6">
                <label for="pf-phone" class="form-label small fw-semibold">Số điện thoại</label>
                <input id="pf-phone" v-model="form.phoneNumber" type="tel" class="form-control rounded-xl bg-light" />
              </div>
              <div class="col-12 col-sm-6">
                <label for="pf-address" class="form-label small fw-semibold">Địa chỉ giao hàng</label>
                <input id="pf-address" v-model="form.address" type="text" class="form-control rounded-xl bg-light" />
              </div>
            </div>
            <div class="d-flex justify-content-end">
              <button type="submit" :disabled="saving" class="btn btn-success rounded-xl fw-semibold px-4">
                <span v-if="saving" class="spinner-border spinner-border-sm me-1"></span>
                {{ saving ? 'Đang cập nhật...' : 'Cập nhật' }}
              </button>
            </div>
          </form>
        </div>

        <!-- Tab: Change Password -->
        <div v-if="activeTab === 'password'" class="bg-white rounded-xl border shadow-sm p-4" style="border-color:#f3f4f6;">
          <h3 class="fw-bold text-dark small mb-4">Đổi mật khẩu</h3>

          <div v-if="passwordError" class="alert alert-danger py-2 rounded-xl small fw-medium mb-3">{{ passwordError }}</div>
          <div v-if="passwordSuccess" class="alert alert-success d-flex align-items-center gap-2 py-2 rounded-xl mb-3">
            <CheckIcon style="width:16px;height:16px;flex-shrink:0;" />
            <span class="small fw-medium">Đổi mật khẩu thành công!</span>
          </div>

          <form @submit.prevent="changePassword" style="max-width:28rem;">
            <div class="mb-3">
              <label for="pw-current" class="form-label small fw-semibold">Mật khẩu hiện tại</label>
              <div class="input-group">
                <input id="pw-current" v-model="passwordForm.currentPassword"
                  :type="showCurrentPw ? 'text' : 'password'" required
                  class="form-control rounded-start-xl bg-light" placeholder="••••••••" />
                <button type="button" @click="showCurrentPw = !showCurrentPw"
                  class="btn btn-outline-secondary rounded-end-xl border-start-0" style="border-color:#dee2e6;">
                  <EyeIcon v-if="!showCurrentPw" style="width:16px;height:16px;" />
                  <EyeSlashIcon v-else style="width:16px;height:16px;" />
                </button>
              </div>
            </div>
            <div class="mb-3">
              <label for="pw-new" class="form-label small fw-semibold">Mật khẩu mới</label>
              <div class="input-group">
                <input id="pw-new" v-model="passwordForm.newPassword"
                  :type="showNewPw ? 'text' : 'password'" required
                  class="form-control rounded-start-xl bg-light" placeholder="Ít nhất 8 ký tự" />
                <button type="button" @click="showNewPw = !showNewPw"
                  class="btn btn-outline-secondary rounded-end-xl border-start-0" style="border-color:#dee2e6;">
                  <EyeIcon v-if="!showNewPw" style="width:16px;height:16px;" />
                  <EyeSlashIcon v-else style="width:16px;height:16px;" />
                </button>
              </div>
            </div>
            <div class="mb-4">
              <label for="pw-confirm" class="form-label small fw-semibold">Xác nhận mật khẩu mới</label>
              <input id="pw-confirm" v-model="passwordForm.confirmPassword" type="password" required
                class="form-control rounded-xl bg-light" placeholder="••••••••" />
            </div>
            <button type="submit" :disabled="saving" class="btn btn-success rounded-xl fw-semibold px-4">
              <span v-if="saving" class="spinner-border spinner-border-sm me-1"></span>
              {{ saving ? 'Đang cập nhật...' : 'Cập nhật' }}
            </button>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>
