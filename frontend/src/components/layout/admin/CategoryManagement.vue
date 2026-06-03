<template>
  <div class="p-4 min-vh-100" style="background: var(--ff-bg-admin); ">

    <!-- Header -->
    <div class="d-flex align-items-center justify-content-between mb-4">
      <div>
        <h1 class="fs-5 fw-bold text-dark">Quản lý danh mục</h1>
        <p class="small text-muted mt-1">Tổng cộng {{ filteredCategories.length }} danh mục</p>
      </div>
      <button
        @click="openAdd"
        class="btn btn-success d-flex align-items-center gap-2 fw-semibold small rounded-3 shadow-sm"
      >
        <PlusIcon style="width:16px;height:16px;" />
        Thêm danh mục
      </button>
    </div>

    <!-- Table -->
    <div class="bg-white rounded-2 border shadow-sm overflow-hidden">
      <table class="table table-hover ff-table mb-0" style="font-size: 0.9rem;">
        <thead>
          <tr>
            <th class="px-4 py-3">STT</th>
            <th class="px-4 py-3">Tên danh mục</th>
            <th class="px-4 py-3">Trạng thái</th>
            <th class="px-4 py-3 text-center">Thao tác</th>
          </tr>
        </thead>
        <tbody>
          <tr v-if="filteredCategories.length === 0">
            <td colspan="4" class="text-center py-5 text-muted">Không có danh mục nào</td>
          </tr>
          <tr
            v-for="(cat, index) in paginatedCategories"
            :key="cat.categoryId"
          >
            <td class="px-4 py-3 text-muted">{{ (currentPage - 1) * itemsPerPage + index + 1 }}</td>
            <td class="px-4 py-3 fw-semibold text-dark">{{ cat.categoryName }}</td>
            <td class="px-4 py-3">
              <span
                class="badge rounded-pill px-3 py-2"
                :style="cat.isActive ? 'background:#ebf2ee;color:#4e7c66;' : 'background:#f0f0f0;color:#6c757d;'"
              >
                {{ cat.isActive ? 'Đang hoạt động' : 'Đã ẩn' }}
              </span>
            </td>
            <td class="px-4 py-3">
              <div class="d-flex align-items-center justify-content-center gap-2">
                <button @click="openEdit(cat)" class="btn btn-sm btn-outline-primary rounded-3" title="Sửa">
                  <PencilSquareIcon style="width:16px;height:16px;" />
                </button>
                <button 
                  @click="toggleActive(cat)" 
                  class="btn btn-sm rounded-3" 
                  :class="cat.isActive ? 'btn-outline-warning' : 'btn-outline-success'"
                  :title="cat.isActive ? 'Khóa' : 'Mở khóa'"
                >
                  <component :is="cat.isActive ? LockClosedIcon : LockOpenIcon" style="width:16px;height:16px;" />
                </button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>

      <!-- Pagination Footer (Bootstrap 5) -->
      <div v-if="totalPages > 1" class="d-flex flex-column flex-md-row align-items-center justify-content-between bg-white p-3 border-top gap-3">
        <div class="small text-muted">
          Hiển thị <b>{{ (currentPage - 1) * itemsPerPage + 1 }}</b> - <b>{{ Math.min(currentPage * itemsPerPage, filteredCategories.length) }}</b> trên tổng số <b>{{ filteredCategories.length }}</b> danh mục
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

    <!-- Modal Thêm / Sửa -->
    <Teleport to="body">
      <div v-if="showModal" class="ff-modal-overlay d-flex align-items-center justify-content-center">
        <div class="position-absolute top-0 start-0 w-100 h-100" style="background:rgba(0,0,0,0.5);" @click="closeModal" />
        <div
          class="bg-white rounded-4 shadow-lg w-100 p-4 position-relative"
          style="max-width: 480px; z-index: 10; 'Plus Jakarta Sans', sans-serif;"
        >
          <div class="d-flex align-items-center justify-content-between mb-3">
            <h2 class="fw-bold text-dark fs-6 mb-0">
              {{ isEditing ? 'Chỉnh sửa danh mục' : 'Thêm danh mục mới' }}
            </h2>
            <button @click="closeModal" class="btn btn-sm btn-light rounded-circle">
              <XMarkIcon style="width:16px;height:16px;" class="text-muted" />
            </button>
          </div>

          <div class="d-flex flex-column gap-3">
            <!-- Tên danh mục -->
            <div>
              <label class="form-label small fw-semibold text-muted">
                Tên danh mục <span class="text-danger">*</span>
              </label>
              <input
                v-model="form.categoryName"
                type="text"
                placeholder="VD: Rau củ quả"
                class="form-control rounded-3"
              />
            </div>

            <!-- Trạng thái -->
            <div>
              <label class="form-label small fw-semibold text-muted">Trạng thái</label>
              <div class="d-flex gap-4">
                <label class="d-flex align-items-center gap-2" style="cursor: pointer;">
                  <input type="radio" v-model="form.isActive" :value="true" class="form-check-input" />
                  <span class="small text-dark">Đang hoạt động</span>
                </label>
                <label class="d-flex align-items-center gap-2" style="cursor: pointer;">
                  <input type="radio" v-model="form.isActive" :value="false" class="form-check-input" />
                  <span class="small text-dark">Đã ẩn</span>
                </label>
              </div>
            </div>
          </div>

          <div class="d-flex gap-3 mt-4">
            <button
              @click="closeModal"
              class="btn btn-outline-secondary flex-grow-1 rounded-3 fw-semibold small"
            >
              Hủy
            </button>
            <button
              @click="saveCategory"
              class="btn btn-success flex-grow-1 rounded-3 fw-semibold small"
            >
              Lưu
            </button>
          </div>
        </div>
      </div>
    </Teleport>


  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import apiClient from '@/api/axios' // Đảm bảo bạn đã tạo file axios.js như hướng dẫn trước
import { toast } from '@/utils/toast'
import {
  PlusIcon,
  PencilSquareIcon,
  LockClosedIcon,
  LockOpenIcon,
  XMarkIcon,
  ChevronLeftIcon,
  ChevronRightIcon
} from '@heroicons/vue/24/outline'

// ── State ──────────────────────────────────────────────────────────────────
const showModal = ref(false)
const isEditing = ref(false)
const loading = ref(false)
const currentPage = ref(1)
const itemsPerPage = ref(10)

const emptyForm = () => ({ categoryId: 0, categoryName: '', isActive: true })
const form = ref(emptyForm())
const categories = ref([])

// ── Computed ───────────────────────────────────────────────────────────────
const filteredCategories = computed(() => categories.value)

const totalPages = computed(() => Math.ceil(filteredCategories.value.length / itemsPerPage.value))

const paginatedCategories = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  return filteredCategories.value.slice(start, start + itemsPerPage.value)
})

// ── Load Data từ Backend ────────────────────────────────────────────────────
const fetchCategories = async () => {
  loading.value = true
  try {
    // Gọi API lấy danh sách (GET /api/Category)
    const response = await apiClient.get('/Category');
    categories.value = response.data.data || response.data;
  } catch (error) {
    console.error("Lỗi khi tải danh mục:", error);
    toast.error("Không thể tải danh mục từ máy chủ!");
  } finally {
    loading.value = false;
    if (currentPage.value > totalPages.value) {
      currentPage.value = Math.max(1, totalPages.value)
    }
  }
}

onMounted(fetchCategories);

// ── Helpers ────────────────────────────────────────────────────────────────

/**
 * Kiểm tra form danh mục có hợp lệ
 * @returns {boolean} true nếu dữ liệu hợp lệ
 */
const validateForm = () => {
  // Kiểm tra tên danh mục không trống
  if (!form.value.categoryName.trim()) {
    toast.warning('Vui lòng nhập đầy đủ thông tin!')
    return false
  }
  return true
}

/**
 * Trích xuất error message từ API response
 * @param {Error} error - Error object
 * @returns {string} Error message đã format
 */
const getErrorMessage = (error) => {
  return error.response?.data?.message || 
         error.response?.data?.Message || 
         error.message
}

// ── Methods ────────────────────────────────────────────────────────────────

function openAdd() {
  isEditing.value = false
  form.value = emptyForm()
  showModal.value = true
}

function openEdit(cat) {
  isEditing.value = true
  form.value = { ...cat }
  showModal.value = true
}

function closeModal() {
  showModal.value = false
  form.value = emptyForm()
}

/**
 * Lưu danh mục (thêm mới hoặc cập nhật)
 * Logic:
 * 1. Kiểm tra dữ liệu
 * 2. Gửi API (POST để thêm, PUT để sửa)
 * 3. Reload danh sách
 */
async function saveCategory() {
  // STEP 1: Validate dữ liệu
  if (!validateForm()) return

  try {
    // STEP 2: Chọn endpoint & HTTP method
    const isAddNew = !isEditing.value
    const endpoint = isAddNew ? '/Category/add' : '/Category/update'
    const method = isAddNew ? 'post' : 'put'
    
    // STEP 3: Gửi API
    await apiClient[method](endpoint, form.value)
    
    // STEP 4: Reload danh sách và đóng modal
    await fetchCategories()
    closeModal()
    toast.success(isEditing.value ? 'Cập nhật danh mục thành công!' : 'Thêm danh mục mới thành công!')
  } catch (error) {
    toast.error("Lỗi khi lưu dữ liệu: " + getErrorMessage(error))
  }
}

async function toggleActive(cat) {
  try {
    const payload = {
      categoryId: cat.categoryId,
      categoryName: cat.categoryName,
      isActive: !cat.isActive
    }
    await apiClient.put('/Category/update', payload)
    await fetchCategories()
    toast.success(cat.isActive ? 'Khóa danh mục thành công!' : 'Mở khóa danh mục thành công!')
  } catch (error) {
    toast.error('Lỗi khi cập nhật danh mục: ' + getErrorMessage(error))
  }
}
</script>

<style scoped>
.ff-modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: 1050;
}
</style>