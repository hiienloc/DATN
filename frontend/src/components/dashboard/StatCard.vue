<template>
  <div class="card" :class="danger ? 'border border-danger bg-danger-100' : ''">
    <div class="d-flex align-items-center justify-content-between mb-3">
      <div
        class="rounded p-2"
        :class="iconBg"
        style="width: 2.25rem; height: 2.25rem; display: flex; align-items: center; justify-content: center; font-size: 1rem;"
      >
        {{ emoji }}
      </div>
      <span
        class="badge rounded-pill small"
        :class="danger ? 'bg-danger bg-opacity-25 text-danger' : 'bg-success bg-opacity-25 text-success'"
      >
        {{ badge }}
      </span>
    </div>
    <div
      class="small fw-semibold text-uppercase"
      :class="danger ? 'text-danger' : 'text-muted'"
      style="letter-spacing: 0.05em; font-size: 0.6875rem;"
    >
      {{ label }}
    </div>
    <div
      class="fw-bold mt-2 lh-sm"
      :class="danger ? 'text-danger' : 'text-dark'"
      style="font-size: 1.5rem;"
    >
      {{ value }}
    </div>
  </div>
</template>

<script setup>
defineProps({
  label:   { type: String, required: true },
  value:   { type: String, required: true },
  badge:   { type: String, required: true },
  emoji:   { type: String, required: true },
  iconBg:  { type: String, default: 'bg-green-100' },
  danger:  { type: Boolean, default: false },
})
</script>
