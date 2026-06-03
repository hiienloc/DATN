<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import apiClient from '@/api/axios'
import { toast } from '@/utils/toast'
import {
  MagnifyingGlassIcon,
  PlusIcon,
  ArrowPathIcon,
  ExclamationTriangleIcon,
  XMarkIcon as XCircleIcon,
  ChevronLeftIcon,
  ChevronRightIcon,
  ClockIcon
} from '@heroicons/vue/24/outline'

const error = ref(null)

const props = defineProps({
  productId: {
    type: [Number, String],
    default: null
  },
  filter: {
    type: String,
    default: 'all'
  }
})

// const searchQuery = ref('')
const filterStatus = ref(props.filter || 'all') // all, low, out

const inventoryItems = ref([])
const loading = ref(false)

// Pagination
const currentPage = ref(1)
const itemsPerPage = ref(10)

const fetchInventory = async () => {
  loading.value = true
  error.value = null
  try {
    const response = await apiClient.get('/Inventory')
    const data = response.data.data || response.data
    inventoryItems.value = Array.isArray(data) ? data : []
  } catch (err) {
    console.error("Lỗi tải tồn kho:", err)
    error.value = "Không thể tải dữ liệu tồn kho. Vui lòng kiểm tra kết nối API."
    inventoryItems.value = []
  } finally {
    loading.value = false
    // Reset an toàn trang hiện tại nếu tổng số trang thay đổi vượt mốc
    if (currentPage.value > totalPages.value) {
      currentPage.value = Math.max(1, totalPages.value)
    }
  }
}

onMounted(async () => {
  await fetchInventory()

  if (props.productId) {
    const item = inventoryItems.value.find(i => i.productId == props.productId)
    if (item) {
      openUpdateInventory(item)
    }
  }
})

const saving = ref(false)

// Update Inventory (manual adjust)
const showUpdateModal = ref(false)
const updateItem = ref(null)
const updateQuantity = ref(0)
const updateMinStock = ref(0)
const updateNote = ref('')

const openUpdateInventory = (item) => {
  updateItem.value = item
  updateQuantity.value = 0
  updateMinStock.value = item.minStockLevel || 0
  updateNote.value = ''
  showUpdateModal.value = true
}

const confirmUpdateInventory = async () => {
  if (!updateItem.value) return
  if (updateQuantity.value === 0) {
    toast.warning('Vui lòng nhập đầy đủ thông tin!')
    return
  }
  if (!updateNote.value.trim()) {
    toast.warning('Vui lòng nhập đầy đủ thông tin!')
    return
  }
  saving.value = true
  try {
    const payload = {
      quantityChange: updateQuantity.value,
      minStockLevel: updateMinStock.value,
      note: updateNote.value
    }
    await apiClient.put(`/Inventory/${updateItem.value.id || updateItem.value.inventoryId}`, payload)
    await fetchInventory()
    showUpdateModal.value = false
    toast.success('Cập nhật tồn kho thành công!')
  } catch (err) {
    toast.error('Lỗi khi cập nhật tồn kho: ' + handleApiError(err))
  } finally {
    saving.value = false
  }
}

// Transaction History
const showHistoryModal = ref(false)
const historyLoading = ref(false)
const transactionHistory = ref([])
const historyProduct = ref(null)

const openHistory = async (item) => {
  historyProduct.value = item
  showHistoryModal.value = true
  historyLoading.value = true
  transactionHistory.value = []
  try {
    const response = await apiClient.get(`/Inventory/${item.id}/transactions`)
    transactionHistory.value = response.data.data || response.data || []
  } catch (err) {
    toast.error('Lỗi khi tải lịch sử: ' + handleApiError(err))
  } finally {
    historyLoading.value = false
  }
}

const filteredItems = computed(() => {
  if (!Array.isArray(inventoryItems.value)) return []

  return inventoryItems.value.filter(item => {
    if (!item) return false

    let matchStatus = true
    const current = item.quantityInStock || 0
    const min = item.minStockLevel || 0

    if (filterStatus.value === 'low') {
      matchStatus = current > 0 && current <= min
    } else if (filterStatus.value === 'out') {
      matchStatus = current === 0
    }

    return matchStatus
  })
})

// Reset về trang 1 khi đổi bộ lọc
watch([filterStatus], () => {
  currentPage.value = 1
})

watch(() => props.filter, (newVal) => {
  if (newVal) filterStatus.value = newVal
})

const totalPages = computed(() => Math.ceil(filteredItems.value.length / itemsPerPage.value))

const paginatedItems = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  return filteredItems.value.slice(start, start + itemsPerPage.value)
})

const getStatusDetails = (current, min) => {
  if (current === 0) return { label: 'Hết hàng', bg: '#fde8e8', color: '#dc3545' }
  if (current <= min) return { label: 'Sắp hết', bg: '#fff8e1', color: '#f59e0b' }
  return { label: 'Còn hàng', bg: '#ebf2ee', color: '#4e7c66' }
}

const handleApiError = (error) => {
  let msg = error.message
  if (typeof error.response?.data === 'string') {
    msg = error.response.data
  } else if (error.response?.data) {
    msg = error.response.data.message || error.response.data.title || msg
    if (error.response.data.errors) {
      msg += '\n' + Object.values(error.response.data.errors).flat().join('\n')
    }
  }
  return msg
}

// Form nhập kho tổng hợp
const allProducts = ref([])
const showGeneralImportModal = ref(false)
const generalImportForm = ref({
  productId: null,
  quantity: 0,
  minStockLevel: 0,
  note: ''
})

const fetchProducts = async () => {
  try {
    const response = await apiClient.get('/Product')
    allProducts.value = response.data.data || response.data
  } catch (err) {
    console.error("Lỗi tải danh sách sản phẩm:", err)
  }
}

const openGeneralImport = async () => {
  if (allProducts.value.length === 0) {
    await fetchProducts()
  }
  generalImportForm.value = { productId: null, quantity: 0, minStockLevel: 0, note: '' }
  showGeneralImportModal.value = true
}

const confirmGeneralImport = async () => {
  if (!generalImportForm.value.productId) {
    toast.warning('Vui lòng nhập đầy đủ thông tin')
    return
  }
  if (generalImportForm.value.quantity <= 0) {
    toast.warning('Vui lòng nhập đầy đủ thông tin')
    return
  }
  if (!generalImportForm.value.note.trim()) {
    toast.warning('Vui lòng nhập đầy đủ thông tin')
    return
  }

  saving.value = true
  try {
    const payload = {
      productId: generalImportForm.value.productId,
      quantity: generalImportForm.value.quantity,
      minStockLevel: generalImportForm.value.minStockLevel,
      note: generalImportForm.value.note
    }
    await apiClient.post('/Inventory/import', payload)
    await fetchInventory()
    showGeneralImportModal.value = false
    toast.success('Nhập kho thành công!')
  } catch (err) {
    toast.error("Lỗi khi nhập hàng: " + handleApiError(err))
  } finally {
    saving.value = false
  }
}
</script>

<template>
  <div class="p-4 min-vh-100" style="background:var(--ff-bg-admin); ">
    <!-- Error Alert -->
    <div v-if="error" class="alert alert-danger d-flex align-items-center gap-2 small mb-4">
      <ExclamationTriangleIcon style="width:20px;height:20px;" />
      <span class="fw-medium">{{ error }}</span>
    </div>

    <!-- Header -->
    <div class="d-flex align-items-center justify-content-between mb-4">
      <div>
        <h1 class="fs-5 fw-bold text-dark mb-0">Quản lý Tồn kho</h1>
        <p class="small text-muted mt-1 mb-0">Theo dõi số lượng sản phẩm, cảnh báo hết hàng và nhập kho</p>
      </div>
      <div class="d-flex align-items-center gap-2">
        <button @click="fetchInventory" class="btn btn-outline-secondary d-flex align-items-center gap-2 fw-medium small rounded-3">
          <ArrowPathIcon style="width:16px;height:16px;" />
          Đồng bộ
        </button>
        <button @click="openGeneralImport" class="btn btn-success d-flex align-items-center gap-2 fw-semibold small rounded-3 shadow-sm">
          <PlusIcon style="width:16px;height:16px;" />
          Nhập kho
        </button>
      </div>
    </div>

    <!-- Filters -->
    <div class="bg-white p-3 rounded-2 shadow-sm border mb-4">
      <div class="d-flex flex-wrap align-items-center justify-content-end gap-3">
        <div class="btn-group" role="group">
          <button
            @click="filterStatus = 'all'"
            :class="filterStatus === 'all' ? 'btn-success' : 'btn-outline-secondary'"
            class="btn btn-sm fw-medium"
          >
            Tất cả
          </button>
          <button
            @click="filterStatus = 'low'"
            :class="filterStatus === 'low' ? 'btn-warning' : 'btn-outline-secondary'"
            class="btn btn-sm fw-medium"
          >
            Sắp hết
          </button>
          <button
            @click="filterStatus = 'out'"
            :class="filterStatus === 'out' ? 'btn-danger' : 'btn-outline-secondary'"
            class="btn btn-sm fw-medium"
          >
            Hết hàng
          </button>
        </div>
      </div>
    </div>

    <!-- Inventory Table -->
    <div class="bg-white rounded-2 shadow-sm border overflow-hidden">
      <table class="table table-hover mb-0" style="font-size: 0.9rem;">
        <thead>
          <tr>
            <th class="px-4 py-3">Mã SP</th>
            <th class="px-4 py-3">Sản phẩm</th>
            <th class="px-4 py-3 text-center">Tồn kho</th>
            <th class="px-4 py-3 text-center">Mức tối thiểu</th>
            <th class="px-4 py-3">Trạng thái</th>
            <th class="px-4 py-3">Cập nhật cuối</th>
            <th class="px-4 py-3 text-end">Thao tác</th>
          </tr>
        </thead>
        <tbody>
          <tr v-if="loading">
            <td colspan="7" class="text-center py-5 text-muted">Đang tải dữ liệu...</td>
          </tr>
          <tr v-else-if="filteredItems.length === 0">
            <td colspan="7" class="text-center py-5 text-muted">
              Không tìm thấy sản phẩm nào phù hợp với điều kiện lọc.
            </td>
          </tr>
          <tr v-for="item in paginatedItems" :key="item.id">
            <td class="px-4 py-3 fw-semibold text-dark">{{ item.productCode }}</td>
            <td class="px-4 py-3 fw-semibold text-dark">{{ item.productName }}</td>
            <td class="px-4 py-3 text-center">
              <!-- ✅ Sửa: minimumStockLevel → minStockLevel -->
              <span class="fw-bold fs-6" :style="{ color: item.quantityInStock <= item.minStockLevel ? '#dc3545' : '#212529' }">
                {{ item.quantityInStock }}
              </span>
            </td>
            <td class="px-4 py-3 text-center text-muted">
              {{ item.minStockLevel }} <!-- ✅ Sửa -->
            </td>
            <td class="px-4 py-3">
              <!-- ✅ Sửa: minimumStockLevel → minStockLevel -->
              <span
                class="badge rounded-pill px-3 py-2 fw-medium"
                :style="{ background: getStatusDetails(item.quantityInStock, item.minStockLevel).bg, color: getStatusDetails(item.quantityInStock, item.minStockLevel).color }"
              >
                {{ getStatusDetails(item.quantityInStock, item.minStockLevel).label }}
              </span>
            </td>
            <td class="px-4 py-3 text-muted">{{ item.lastUpdated ? new Date(item.lastUpdated).toLocaleDateString('vi-VN') : '—' }}</td>
            <td class="px-4 py-3 text-end">
                <div class="d-flex justify-content-end gap-2">
                  <button
                    @click="openHistory(item)"
                    class="btn btn-sm btn-outline-secondary rounded-3 fw-medium d-flex align-items-center gap-1"
                  >
                    <ClockIcon style="width:14px;height:14px;" />
                    Lịch sử
                  </button>
                  <button
                    @click="openUpdateInventory(item)"
                    class="btn btn-sm btn-outline-primary rounded-3 fw-medium"
                  >
                    Cập nhật
                  </button>
                </div>
            </td>
          </tr>
        </tbody>
      </table>

      <!-- Pagination Footer (Bootstrap 5) -->
      <div v-if="totalPages > 1" class="d-flex flex-column flex-md-row align-items-center justify-content-between bg-white p-3 border-top gap-3">
        <div class="small text-muted">
          Hiển thị <b>{{ (currentPage - 1) * itemsPerPage + 1 }}</b> - <b>{{ Math.min(currentPage * itemsPerPage, filteredItems.length) }}</b> trên tổng số <b>{{ filteredItems.length }}</b> bản ghi
        </div>
        <nav>
          <ul class="pagination pagination-sm mb-0 gap-1">
            <!-- Nút Trước -->
            <li class="page-item" :class="{ disabled: currentPage === 1 }">
              <button class="page-link border-0 rounded-2 px-3 bg-light text-dark d-flex align-items-center gap-1" 
                      @click="currentPage > 1 ? currentPage-- : null">
                <ChevronLeftIcon style="width: 14px; height: 14px;" /> Trước
              </button>
            </li>
            
            <!-- Số trang -->
            <li v-for="page in totalPages" :key="page" class="page-item" :class="{ active: currentPage === page }">
              <button class="page-link border-0 rounded-2 px-3 fw-semibold transition-all"
                      :style="currentPage === page 
                        ? 'background-color: #4e7c66; color: white; transform: scale(1.05);' 
                        : 'background-color: #f8f9fa; color: #495057;'"
                      @click="currentPage = page">
                {{ page }}
              </button>
            </li>

            <!-- Nút Sau -->
            <li class="page-item" :class="{ disabled: currentPage === totalPages }">
              <button class="page-link border-0 rounded-2 px-3 bg-light text-dark d-flex align-items-center gap-1" 
                      @click="currentPage < totalPages ? currentPage++ : null">
                Sau <ChevronRightIcon style="width: 14px; height: 14px;" />
              </button>
            </li>
          </ul>
        </nav>
      </div>
    </div>
  </div>

    <!-- Modal Update Inventory (manual adjust) -->
    <Teleport to="body">
      <div v-if="showUpdateModal" class="ff-modal-container">
        <div class="ff-modal-backdrop" @click="showUpdateModal = false" />
        <div class="ff-modal-content" style="max-width:480px;" @click.stop>
          <div class="p-4 border-bottom d-flex justify-content-between align-items-center">
            <h3 class="fw-bold text-dark fs-6 mb-0">Cập nhật tồn kho</h3>
            <button @click="showUpdateModal = false" class="btn btn-sm btn-light rounded-circle">
              <XCircleIcon style="width:16px;height:16px;" class="text-muted" />
            </button>
          </div>
          <div class="p-4" v-if="updateItem">
            <div class="mb-4 p-3 rounded-3" style="background:#f8f9fa;">
              <div class="d-flex justify-content-between mb-2">
                <span class="small text-muted">Sản phẩm:</span>
                <span class="fw-semibold text-dark">{{ updateItem.productName }} ({{ updateItem.productCode }})</span>
              </div>
              <div class="d-flex justify-content-between">
                <span class="small text-muted">Tồn kho hiện tại:</span>
                <span class="fw-bold" :style="{ color: updateItem.quantityInStock <= updateItem.minStockLevel ? '#dc3545' : '#4e7c66' }">
                  {{ updateItem.quantityInStock }}
                </span>
              </div>
            </div>
            <div class="d-flex flex-column gap-3">
              <div>
                <label class="form-label small fw-semibold text-muted">Số lượng điều chỉnh (có thể âm hoặc dương)</label>
                <input
                  type="number"
                  v-model.number="updateQuantity"
                  class="form-control text-center fw-bold fs-5 rounded-3"
                  placeholder="Nhập số lượng điều chỉnh"
                >
              </div>
              <div>
                <label class="form-label small fw-semibold text-muted">Mức tồn kho tối thiểu</label>
                <input
                  type="number"
                  v-model.number="updateMinStock"
                  class="form-control rounded-3"
                  placeholder="Mức cảnh báo sắp hết hàng"
                >
              </div>
              <div>
                <textarea
                  v-model="updateNote"
                  rows="2"
                  class="form-control rounded-3"
                  placeholder="VD: Kiểm kê kho, xuất hủy, điều chỉnh thực tế..."
                ></textarea>
              </div>
            </div>
          </div>
          <div class="p-4 border-top d-flex justify-content-end gap-3">
            <button @click="showUpdateModal = false" class="btn btn-outline-secondary rounded-3 fw-semibold small">Hủy</button>
            <button
              @click="confirmUpdateInventory"
              :disabled="saving"
              class="btn btn-primary rounded-3 fw-semibold small"
            >
              <span v-if="saving" class="spinner-border spinner-border-sm me-1"></span>
              {{ saving ? 'Đang xử lý...' : 'Lưu' }}
            </button>
          </div>
        </div>
      </div>
      </Teleport>
        <!-- Modal Nhập Kho Tổng Hợp -->
    <Teleport to="body">
      <div v-if="showGeneralImportModal" class="ff-modal-container">
        <div class="ff-modal-backdrop" @click="showGeneralImportModal = false" />
        <div class="ff-modal-content" style="max-width:480px;" @click.stop>
          <div class="p-4 border-bottom d-flex justify-content-between align-items-center">
            <h3 class="fw-bold text-dark fs-6 mb-0">Nhập kho sản phẩm</h3>
            <button @click="showGeneralImportModal = false" class="btn btn-sm btn-light rounded-circle">
              <XCircleIcon style="width:16px;height:16px;" class="text-muted" />
            </button>
          </div>
          <div class="p-4 d-flex flex-column gap-3">
            <div>
              <label class="form-label small fw-semibold text-muted">Chọn sản phẩm <span class="text-danger">*</span></label>
              <select v-model="generalImportForm.productId" class="form-select rounded-3">
                <option :value="null" disabled>-- Chọn sản phẩm --</option>
                <option v-for="p in allProducts" :key="p.productId" :value="p.productId">
                  {{ p.productCode ? `[${p.productCode}] ` : '' }}{{ p.productName }}
                </option>
              </select>
            </div>
            <div>
              <label class="form-label small fw-semibold text-muted">Số lượng nhập <span class="text-danger">*</span></label>
              <input
                type="number"
                v-model.number="generalImportForm.quantity"
                class="form-control rounded-3"
                min="1"
              >
            </div>
            <div>
              <label class="form-label small fw-semibold text-muted">Mức tồn kho tối thiểu <span class="text-danger">*</span></label>
              <input
                type="number"
                v-model.number="generalImportForm.minStockLevel"
                class="form-control rounded-3"
                min="0"
              >
            </div>
            <div>
              <label class="form-label small fw-semibold text-muted">Ghi chú</label>
              <textarea
                v-model="generalImportForm.note"
                rows="2"
                class="form-control rounded-3"
                placeholder="VD: Nhập lô hàng mới..."
              ></textarea>
            </div>
          </div>
          <div class="p-4 border-top d-flex justify-content-end gap-3">
            <button @click="showGeneralImportModal = false" class="btn btn-outline-secondary rounded-3 fw-semibold small">Hủy</button>
            <button
              @click="confirmGeneralImport"
              :disabled="!generalImportForm.productId || generalImportForm.quantity <= 0 || saving"
              class="btn btn-success rounded-3 fw-semibold small"
            >
              <span v-if="saving" class="spinner-border spinner-border-sm me-1"></span>
              {{ saving ? 'Đang xử lý...' : 'Lưu' }}
            </button>
          </div>
        </div>
      </div>
    </Teleport>

    <!-- Modal Lịch sử giao dịch -->
    <Teleport to="body">
      <div v-if="showHistoryModal" class="ff-modal-container">
        <div class="ff-modal-backdrop" @click="showHistoryModal = false" />
        <div class="ff-modal-content" style="max-width:800px;" @click.stop>
          <div class="p-4 border-bottom d-flex justify-content-between align-items-center">
            <div>
               <h3 class="fw-bold text-dark fs-6 mb-0">Lịch sử biến động kho</h3>
               <p v-if="historyProduct" class="small text-muted mb-0">{{ historyProduct.productName }} ({{ historyProduct.productCode }})</p>
            </div>
            <button @click="showHistoryModal = false" class="btn btn-sm btn-light rounded-circle">
              <XCircleIcon style="width:16px;height:16px;" class="text-muted" />
            </button>
          </div>
          
          <div class="p-0" style="max-height: 500px; overflow-y: auto;">
            <div v-if="historyLoading" class="text-center py-5">
              <div class="spinner-border text-success" role="status">
                <span class="visually-hidden">Đang tải...</span>
              </div>
            </div>
            <div v-else-if="transactionHistory.length === 0" class="text-center py-5 text-muted small">
              Chưa có giao dịch nào được ghi lại.
            </div>
            <table v-else class="table table-hover mb-0" style="font-size: 0.85rem;">
              <thead class="bg-light sticky-top" style="z-index: 1;">
                <tr>
                  <th class="px-4 py-3">Ngày giờ</th>
                  <th class="px-4 py-3">Loại</th>
                  <th class="px-4 py-3 text-center">Biến động</th>
                  <th class="px-4 py-3">Ghi chú</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="t in transactionHistory" :key="t.transactionId">
                  <td class="px-4 py-3 text-muted">
                    {{ new Date(t.transactionDate).toLocaleString('vi-VN') }}
                  </td>
                  <td class="px-4 py-3">
                    <span 
                      class="badge rounded-pill px-2 py-1 fw-bold text-uppercase" 
                      :style="t.transactionType === 'IMPORT' 
                        ? 'background:#ebf2ee;color:#4e7c66;' 
                        : (t.transactionType === 'EXPORT' ? 'background:#fde8e8;color:#dc3545;' : 'background:#e0f2fe;color:#0284c7;')"
                    >
                      {{ t.transactionType === 'IMPORT' ? 'Nhập kho' : (t.transactionType === 'EXPORT' ? 'Xuất kho' : 'Cập nhật') }}
                    </span>
                  </td>
                  <td class="px-4 py-3 text-center fw-bold" :class="t.quantityChange > 0 ? 'text-success' : 'text-danger'">
                    {{ t.quantityChange > 0 ? '+' : '' }}{{ t.quantityChange }}
                  </td>
                  <td class="px-4 py-3 small text-muted">
                    {{ t.note || '—' }}
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
          
          <div class="p-3 border-top d-flex justify-content-end">
            <button @click="showHistoryModal = false" class="btn btn-outline-secondary rounded-3 fw-semibold small">Đóng</button>
          </div>
        </div>
      </div>
    </Teleport>
</template>

<style scoped>
.ff-modal-container {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: 2000;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 1rem;
}

.ff-modal-backdrop {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(15, 23, 42, 0.4);
  backdrop-filter: blur(8px);
  -webkit-backdrop-filter: blur(8px);
}

.ff-modal-content {
  position: relative;
  width: 100%;
  background: white;
  border-radius: 1.25rem;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
  z-index: 10;
  overflow: hidden;
  animation: modalScaleUp 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
}

@keyframes modalScaleUp {
  from {
    opacity: 0;
    transform: scale(0.95) translateY(10px);
  }
  to {
    opacity: 1;
    transform: scale(1) translateY(0);
  }
}
</style>