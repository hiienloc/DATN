<template>
  <div class="p-4 min-vh-100" style="background:var(--ff-bg-admin); ">

    <!-- Header -->
    <div class="d-flex align-items-center justify-content-between mb-4">
      <div>
        <h1 class="fs-5 fw-bold text-dark mb-0">Quản lý tài khoản khách hàng</h1>
        <p class="small text-muted mt-1 mb-0">Tổng cộng {{ filteredCustomers.length }} tài khoản</p>
      </div>
    </div>

    <!-- Search & Filter -->
    <div class="d-flex justify-content-end mb-3">
      <select v-model="filterStatus" class="form-select form-select-sm" style="width:auto;min-width:160px; border-radius: 4px;">
        <option value="">Tất cả trạng thái</option>
        <option value="active">Hoạt động</option>
        <option value="locked">Khóa</option>
      </select>
    </div>

    <!-- Table -->
    <div class="bg-white shadow-sm border overflow-hidden" style="border-color:#f3f4f6; border-radius: 4px;">
      <table class="table table-hover ff-table mb-0">
        <thead>
          <tr>
            <th style="width:60px;">STT</th>
            <th>Tên khách hàng</th>
            <th>Liên hệ</th>
            <th>Ngày tạo</th>
            <th style="width:120px;">Trạng thái</th>
            <th class="text-center" style="width:140px;">Thao tác</th>
          </tr>
        </thead>
        <tbody>
          <tr v-if="loading">
            <td colspan="6" class="text-center py-5 text-muted">Đang tải dữ liệu...</td>
          </tr>
          <tr v-else-if="filteredCustomers.length === 0">
            <td colspan="6" class="text-center py-5 text-muted">Không có tài khoản nào</td>
          </tr>
          <tr v-for="(customer, index) in paginatedCustomers" :key="customer.id">
            <td class="text-muted fw-medium">{{ (currentPage - 1) * itemsPerPage + index + 1 }}</td>
            <td class="fw-semibold text-dark">{{ customer.name }}</td>
            <td>
              <div class="small">{{ customer.phone }}</div>
              <div class="text-muted" style="font-size:0.7rem;">{{ customer.email }}</div>
            </td>
            <td class="small text-muted">{{ formatDate(customer.createAt) }}</td>
            <td>
              <span
                class="badge d-inline-flex align-items-center gap-1"
                :class="customer.isActive ? 'bg-success' : 'bg-danger'"
                style="border-radius: 4px;"
              >
                <span class="bg-white opacity-75" style="width:6px;height:6px;display:inline-block; border-radius: 50%;"></span>
                {{ customer.isActive ? 'Hoạt động' : 'Đã khóa' }}
              </span>
            </td>
            <td>
              <div class="d-flex align-items-center justify-content-center gap-2">
                <button
                  @click="openConfirmToggleLock(customer)"
                  :disabled="!customer.isActive"
                  class="btn btn-sm"
                  :class="!customer.isActive ? 'btn-outline-secondary disabled' : 'btn-outline-danger'"
                  style="font-size:0.75rem; border-radius: 4px;"
                >Khóa</button>
                <button
                  @click="openConfirmToggleLock(customer)"
                  :disabled="customer.isActive"
                  class="btn btn-sm"
                  :class="customer.isActive ? 'btn-outline-secondary disabled' : 'btn-outline-success'"
                  style="font-size:0.75rem; border-radius: 4px;"
                >Mở khóa</button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>

      <!-- Pagination Footer (Bootstrap 5) -->
      <div v-if="totalPages > 1" class="d-flex flex-column flex-md-row align-items-center justify-content-between bg-white p-3 border-top gap-3">
        <div class="small text-muted">
          Hiển thị <b>{{ (currentPage - 1) * itemsPerPage + 1 }}</b> - <b>{{ Math.min(currentPage * itemsPerPage, filteredCustomers.length) }}</b> trên tổng số <b>{{ filteredCustomers.length }}</b> tài khoản
        </div>
        <nav>
          <ul class="pagination pagination-sm mb-0 gap-1">
            <!-- Nút Trước -->
            <li class="page-item" :class="{ disabled: currentPage === 1 }">
              <button class="page-link border-0 px-3 bg-light text-dark d-flex align-items-center gap-1" style="border-radius: 4px;" 
                      @click="currentPage > 1 ? currentPage-- : null">
                <ChevronLeftIcon style="width: 14px; height: 14px;" /> Trước
              </button>
            </li>
            
            <!-- Số trang -->
            <li v-for="page in totalPages" :key="page" class="page-item" :class="{ active: currentPage === page }">
              <button class="page-link border-0 px-3 fw-semibold transition-all" style="border-radius: 4px;"
                      :style="currentPage === page 
                        ? 'background-color: #4e7c66; color: white; transform: scale(1.05);' 
                        : 'background-color: #f8f9fa; color: #495057;'"
                      @click="currentPage = page">
                {{ page }}
              </button>
            </li>

            <!-- Nút Sau -->
            <li class="page-item" :class="{ disabled: currentPage === totalPages }">
              <button class="page-link border-0 px-3 bg-light text-dark d-flex align-items-center gap-1" style="border-radius: 4px;" 
                      @click="currentPage < totalPages ? currentPage++ : null">
                Sau <ChevronRightIcon style="width: 14px; height: 14px;" />
              </button>
            </li>
          </ul>
        </nav>
      </div>
    </div>

    <!-- Hộp thoại xác nhận Khóa / Mở khóa Custom -->
    <Teleport to="body">
      <div v-if="showConfirmModal" class="ff-modal-overlay" @click="showConfirmModal = false">
        <div class="ff-modal-box" @click.stop style="max-width:28rem;">
          <!-- Header -->
          <div class="p-4 border-bottom d-flex justify-content-between align-items-center bg-light">
            <h3 class="fw-extrabold text-dark mb-0" style="font-size:1.1rem;">
              {{ selectedCustomer?.isActive ? 'Khóa tài khoản' : 'Mở khóa tài khoản' }}
            </h3>
            <button
              @click="showConfirmModal = false"
              class="btn btn-sm btn-outline-secondary border px-2 py-1" style="border-radius: 4px;"
            >
              ✕
            </button>
          </div>
          
          <!-- Content -->
          <div class="p-4 text-center">
            <div 
              class="mb-3 d-inline-flex align-items-center justify-content-center"
              :class="selectedCustomer?.isActive ? 'bg-danger bg-opacity-10 text-danger' : 'bg-success bg-opacity-10 text-success'"
              style="width: 60px; height: 60px; font-size: 2rem;"
            >
              {{ selectedCustomer?.isActive ? '🔒' : '🔓' }}
            </div>
            <p class="text-dark fw-bold mb-2">
              Bạn có muốn {{ selectedCustomer?.isActive ? 'khóa' : 'mở khóa' }} tài khoản này không?
            </p>
            <p class="text-muted small mb-0" v-if="selectedCustomer">
              Tài khoản: <span class="fw-semibold text-dark">{{ selectedCustomer.name }}</span>
            </p>
          </div>

          <!-- Footer -->
          <div class="p-4 border-top bg-white d-flex gap-3">
            <button
              @click="showConfirmModal = false"
              class="btn btn-light flex-grow-1 fw-bold py-2" style="border-radius: 4px;"
            >
              Hủy
            </button>
            <button
              @click="executeToggleLock"
              class="btn flex-grow-1 fw-bold py-2" style="border-radius: 4px;"
              :class="selectedCustomer?.isActive ? 'btn-danger' : 'btn-success'"
            >
              Đồng ý
            </button>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import apiClient from '@/api/axios'
import { toast } from '@/utils/toast'
import { ChevronLeftIcon, ChevronRightIcon } from '@heroicons/vue/24/outline'

const props = defineProps({
  searchQuery: { type: String, default: '' }
})

const removeAccents = (str) => {
  return str ? str.normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/đ/g, 'd').replace(/Đ/g, 'D') : ''
}

function formatDate(dateString) {
  if (!dateString || dateString.startsWith('0001-01-01')) return 'N/A'
  const date = new Date(dateString)
  if (isNaN(date.getTime())) return 'N/A'
  return new Intl.DateTimeFormat('vi-VN', {
    year: 'numeric', month: '2-digit', day: '2-digit',
    hour: '2-digit', minute: '2-digit'
  }).format(date)
}

const filterStatus = ref('')
const customers = ref([])
const loading = ref(false)
const currentPage = ref(1)
const itemsPerPage = ref(10)

const fetchCustomers = async () => {
  loading.value = true
  try {
    const res = await apiClient.get('/Auth/customers')
    const raw = res.data.data || res.data || []
    customers.value = raw.map(u => ({
      id: u.userId || u.id,
      name: u.fullName || u.name,
      phone: u.phoneNumber || u.phone || '',
      email: u.email || '',
      isActive: u.isActive,
      createAt: u.createDate || u.createdDate || u.createdAt || u.createAt || null
    }))
  } catch (e) {
    console.error('Lỗi tải danh sách khách hàng:', e)
  } finally {
    loading.value = false
    if (currentPage.value > totalPages.value) {
      currentPage.value = Math.max(1, totalPages.value)
    }
  }
}

onMounted(fetchCustomers)

const filteredCustomers = computed(() =>
  customers.value.filter(c => {
    const matchStatus = !filterStatus.value || (filterStatus.value === 'active' ? c.isActive : !c.isActive)
    
    const query = removeAccents(props.searchQuery).toLowerCase().trim()
    if (!query) return matchStatus
    
    const nameMatch = c.name ? removeAccents(c.name).toLowerCase().includes(query) : false
    const phoneMatch = c.phone ? removeAccents(c.phone).toLowerCase().includes(query) : false
    const emailMatch = c.email ? removeAccents(c.email).toLowerCase().includes(query) : false
    
    return matchStatus && (nameMatch || phoneMatch || emailMatch)
  })
)

const totalPages = computed(() => Math.ceil(filteredCustomers.value.length / itemsPerPage.value))

const paginatedCustomers = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  return filteredCustomers.value.slice(start, start + itemsPerPage.value)
})

watch([filterStatus, () => props.searchQuery], () => {
  currentPage.value = 1
})

const showConfirmModal = ref(false)
const selectedCustomer = ref(null)

const openConfirmToggleLock = (customer) => {
  selectedCustomer.value = customer
  showConfirmModal.value = true
}

const executeToggleLock = async () => {
  if (!selectedCustomer.value) return
  const customer = selectedCustomer.value
  const action = customer.isActive ? 'khóa' : 'mở khóa'
  showConfirmModal.value = false

  try {
    const res = await apiClient.put(`/Auth/${customer.id}/toggle-lock`)
    await fetchCustomers()
    toast.success(res.data?.message || res.data?.Message || `${customer.isActive ? 'Khóa' : 'Mở khóa'} tài khoản ${customer.name} thành công!`)
  } catch (e) {
    const msg = e.response?.data?.message || e.response?.data?.Message || e.message
    toast.error(`Lỗi khi ${action} tài khoản: ` + msg)
  } finally {
    selectedCustomer.value = null
  }
}
</script>

<style scoped>
.ff-modal-overlay {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0, 0, 0, 0.4);
  z-index: 1050;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 1rem;
  backdrop-filter: blur(2px);
}
.ff-modal-box {
  background: white;
  width: 100%;
  border-radius: 4px;
  overflow: hidden;
  box-shadow: 0 10px 25px rgba(0,0,0,0.15);
}
</style>
