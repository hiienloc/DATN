<template>
  <header class="bg-white border-bottom d-flex align-items-center px-3 gap-3 shrink-0" style="height:56px;z-index:1030;">
    <!-- Mobile Sidebar Toggle -->
    <button class="btn border-0 p-1 me-1 d-lg-none text-muted" @click="emit('toggle-sidebar')" aria-label="Mở menu">
      <Bars3Icon style="width:20px;height:20px;" />
    </button>

    <!-- Search -->
    <div class="position-relative" style="max-width:280px;flex:1;">
      <MagnifyingGlassIcon class="position-absolute top-50 translate-middle-y ms-2" style="width:16px;height:16px;color:#9ca3af;left:4px;" />
      <input
        :value="search"
        @input="emit('update:search', $event.target.value)"
        type="text"
        placeholder="Tìm kiếm đơn hàng, sản phẩm..."
        class="form-control form-control-sm bg-light rounded-xl"
        style="padding-left:2rem;border-color:#e5e7eb;"
      />
    </div>

    <!-- Right -->
    <div class="ms-auto d-flex align-items-center gap-2">
      <!-- Notification -->
      <button class="btn-icon position-relative" @click="showNotif = !showNotif">
        <BellIcon style="width:16px;height:16px;" />
        <span class="position-absolute bg-danger rounded-circle border border-white" style="width:8px;height:8px;top:6px;right:6px;"></span>
      </button>

      <!-- Settings -->
      <button class="btn-icon">
        <Cog6ToothIcon style="width:16px;height:16px;" />
      </button>

      <!-- User Dropdown -->
      <div class="position-relative">
        <div
          @click="showUserMenu = !showUserMenu"
          class="d-flex align-items-center gap-2 px-2 py-1 border rounded-pill cursor-pointer"
          style="border-color:#e5e7eb;cursor:pointer;"
          role="button"
        >
          <div class="d-flex align-items-center justify-content-center rounded-circle bg-success text-white fw-semibold" style="width:28px;height:28px;font-size:0.7rem;">
            {{ userInitials }}
          </div>
          <div class="text-end">
            <div class="fw-medium" style="font-size:0.75rem;color:#374151;line-height:1.2;">{{ userName }}</div>
            <div style="font-size:0.6rem;color:#9ca3af;line-height:1.2;">{{ userRole }}</div>
          </div>
        </div>

        <!-- Dropdown Menu -->
        <div v-if="showUserMenu" class="position-absolute end-0 bg-white border rounded-xl shadow-sm py-1" style="top:calc(100% + 8px);width:180px;z-index:1050;border-color:#f3f4f6;">
          <button @click="goToProfile" class="btn btn-link w-100 text-start text-decoration-none text-dark d-flex align-items-center gap-2 px-3 py-2 small">
            <UserIcon style="width:16px;height:16px;" />
            Hồ sơ cá nhân
          </button>
          <hr class="my-1" />
          <button @click="logout" class="btn btn-link w-100 text-start text-decoration-none text-danger d-flex align-items-center gap-2 px-3 py-2 small">
            <ArrowRightOnRectangleIcon style="width:16px;height:16px;" />
            Đăng xuất
          </button>
        </div>

        <!-- Overlay -->
        <div v-if="showUserMenu" @click="showUserMenu = false" class="position-fixed top-0 start-0 w-100 h-100" style="z-index:1040;"></div>
      </div>
    </div>
  </header>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { MagnifyingGlassIcon, BellIcon, Cog6ToothIcon, UserIcon, ArrowRightOnRectangleIcon, Bars3Icon } from '@heroicons/vue/24/outline'

const props = defineProps({
  search: { type: String, default: '' }
})

const emit = defineEmits(['nav-change', 'update:search', 'toggle-sidebar'])

const showNotif = ref(false)
const showUserMenu = ref(false)
const userInfo = ref(null)

const updateUserInfo = () => {
  const token = localStorage.getItem('token')
  const fullName = localStorage.getItem('fullName')
  const role = localStorage.getItem('role')
  if (token && fullName) {
    userInfo.value = { fullName, role }
  } else {
    userInfo.value = null
  }
}

onMounted(() => {
  updateUserInfo()
  window.addEventListener('storage', updateUserInfo)
})

onUnmounted(() => {
  window.removeEventListener('storage', updateUserInfo)
})

const userName = computed(() => userInfo.value?.fullName || 'Admin FreshFarm')

const userInitials = computed(() => {
  const name = userName.value
  const parts = name.trim().split(/\s+/)
  if (parts.length >= 2) return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase()
  return name.substring(0, 2).toUpperCase()
})

const userRole = computed(() => {
  const role = userInfo.value?.role
  if (role === 'Admin') return 'Quản trị hệ thống'
  return role || 'Quản trị hệ thống'
})

const goToProfile = () => {
  showUserMenu.value = false
  emit('nav-change', 'adminProfile')
}

const logout = () => {
  localStorage.removeItem('token')
  localStorage.removeItem('fullName')
  localStorage.removeItem('role')
  localStorage.removeItem('user')
  window.location.href = '/'
}
</script>
