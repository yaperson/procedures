<template>
  <div class="step-list">
    <div 
      v-for="(step, index) in steps" 
      :key="index"
      class="step-item"
      :class="{ 'is-completed': completedSteps[index] }"
      @click="toggleStep(index)"
    >
      <div class="checkbox">
        <svg v-if="completedSteps[index]" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <polyline points="20 6 9 17 4 12"></polyline>
        </svg>
      </div>
      <div class="step-content">
        {{ step }}
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue';

const props = defineProps({
  steps: {
    type: Array,
    required: true,
    default: () => []
  },
  procedureId: {
    type: String,
    required: true
  }
});

const completedSteps = ref({});

onMounted(() => {
  const saved = localStorage.getItem(`procedure_${props.procedureId}_steps`);
  if (saved) {
    try {
      completedSteps.value = JSON.parse(saved);
    } catch (e) {
      console.error('Failed to parse saved steps', e);
    }
  }
});

const toggleStep = (index) => {
  completedSteps.value[index] = !completedSteps.value[index];
  localStorage.setItem(`procedure_${props.procedureId}_steps`, JSON.stringify(completedSteps.value));
};
</script>

<style scoped>
.step-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  margin: 2rem 0;
}

.step-item {
  display: flex;
  align-items: flex-start;
  gap: 1rem;
  padding: 1rem;
  border-radius: 8px;
  background-color: #f9fafb;
  border: 1px solid #e5e7eb;
  cursor: pointer;
  transition: all 0.2s ease;
}

.step-item:hover {
  background-color: #f3f4f6;
  transform: translateY(-2px);
  box-shadow: 0 4px 6px rgba(0,0,0,0.05);
}

.step-item.is-completed {
  background-color: #f3f4f6;
  opacity: 0.7;
}

.step-item.is-completed .step-content {
  text-decoration: line-through;
  color: #6b7280;
}

.checkbox {
  flex-shrink: 0;
  width: 28px;
  height: 28px;
  border-radius: 50%;
  border: 2px solid #d1d5db;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #10b981;
  background: white;
  transition: all 0.2s ease;
}

.step-item.is-completed .checkbox {
  border-color: #10b981;
  background-color: #ecfdf5;
}

.step-content {
  font-size: 1.1rem;
  line-height: 1.5;
  color: #111827;
  transition: color 0.2s ease;
  user-select: none;
}
</style>
