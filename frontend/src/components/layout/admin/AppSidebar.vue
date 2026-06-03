<template>
  <aside class="ff-sidebar" :class="{ 'open': isOpen }">
    <!-- Close button for mobile -->
    <button @click="$emit('close-sidebar')" class="btn-close-sidebar d-lg-none" aria-label="Đóng menu">
      <XMarkIcon style="width:20px;height:20px;" />
    </button>
    <!-- Logo -->
    <div class="ff-sidebar-logo d-flex align-items-center gap-2">
      <!-- Fresh Sprout SVG Icon -->
      <svg width="28" height="28" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" style="flex-shrink:0;">
        <rect width="24" height="24" rx="7" fill="url(#logoBgGradAdmin)" />
        <path d="M12 5C12 5 15 8 15 11.5C15 15 12 18 12 18C12 18 9 15 9 11.5C9 8 12 5 12 5Z" fill="#ffffff" />
        <path d="M12 8V15" stroke="#5edb74" stroke-width="0.8" stroke-linecap="round" opacity="0.3" />
        <path d="M13 10.5C13 10.5 15.5 10.5 16.5 12.5" stroke="#ffffff" stroke-width="1.2" stroke-linecap="round" />
        <defs>
          <linearGradient id="logoBgGradAdmin" x1="0" y1="0" x2="24" y2="24" gradientUnits="userSpaceOnUse">
            <stop stop-color="#4ADE80" />
            <stop offset="1" stop-color="#5edb74" />
          </linearGradient>
        </defs>
      </svg>
      <div>
        <div class="fw-bold" style="font-size:0.95rem;color:#5edb74;letter-spacing:-0.01em;line-height:1.2;">
          Fresh<span class="text-success" style="color:#16a34a!important;">Farm</span>
        </div>
        <div class="text-muted mt-0.5" style="font-size:0.55rem;text-transform:uppercase;letter-spacing:0.08em;line-height:1;">Hệ thống Admin</div>
      </div>
    </div>

    <!-- Nav label -->
    <div class="px-3 pt-3 pb-1 text-muted" style="font-size:0.6rem;text-transform:uppercase;letter-spacing:0.1em;font-weight:600;">
      Trang chủ vận hành
    </div>

    <!-- Nav items -->
    <nav class="flex-grow-1 overflow-auto pb-3">
      <div
        v-for="item in navItems"
        :key="item.key"
        class="nav-item"
        :class="{ active: activeNav === item.key }"
        @click="$emit('nav-change', item.key)"
      >
        <component :is="item.icon" style="width:16px;height:16px;opacity:0.7;flex-shrink:0;" />
        <span>{{ item.label }}</span>
      </div>
    </nav>
  </aside>
</template>

<script setup>
import { defineProps, defineEmits } from 'vue'

defineProps({ activeNav: String, isOpen: Boolean })
defineEmits(['nav-change', 'close-sidebar'])

import {
  ChartBarSquareIcon,
  TagIcon,
  ShoppingBagIcon,
  CubeIcon,
  UsersIcon,
  ClipboardDocumentListIcon,
  ArchiveBoxIcon,
  ChartBarIcon,
  LightBulbIcon,
  XMarkIcon
} from '@heroicons/vue/24/outline'

const navItems = [
  { key: 'dashboard',  label: 'Dashboard',                    icon: ChartBarSquareIcon },
  { key: 'category',   label: 'Quản lý danh mục',             icon: TagIcon },
  { key: 'product',    label: 'Quản lý sản phẩm',             icon: ShoppingBagIcon },
  { key: 'combo',      label: 'Quản lý gói sản phẩm',         icon: CubeIcon },
  { key: 'customer',   label: 'Quản lý tài khoản khách hàng', icon: UsersIcon },
  { key: 'order',      label: 'Quản lý đơn hàng',             icon: ClipboardDocumentListIcon },
  { key: 'inventory',  label: 'Quản lý tồn kho',              icon: ArchiveBoxIcon },
  { key: 'stats',      label: 'Thống kê',          icon: ChartBarIcon },
  { key: 'ai',         label: 'Dự báo nhu cầu tiêu thụ',          icon: LightBulbIcon },
]
</script>
