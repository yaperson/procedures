<template>
  <div class="mermaid-container" v-if="chartText && chartText.trim()">
    <div class="mermaid-body">
      <div v-if="loading && !renderedSvg" class="mermaid-loading">
        <span class="spinner"></span> Chargement du diagramme...
      </div>
      <div class="mermaid" ref="mermaidDiv"></div>
    </div>
  </div>
  <div v-else-if="!chartText || !chartText.trim()" class="mermaid-unavailable">
    <p>Aucun diagramme défini pour cette procédure.</p>
  </div>
</template>

<script setup>
import { onMounted, ref, watch, nextTick } from 'vue';
import mermaid from 'mermaid';

const props = defineProps({
  chartText: {
    type: String,
    default: ''
  }
});

const mermaidDiv = ref(null);
const loading = ref(false);
const renderedSvg = ref(false);
let renderIdCounter = 0;
let isInitialized = false;

const initMermaid = () => {
  if (!isInitialized) {
    try {
      mermaid.initialize({ 
        startOnLoad: false,
        theme: 'neutral',
        securityLevel: 'loose',
        fontFamily: 'system-ui, -apple-system, sans-serif',
        flowchart: {
          htmlLabels: true,
          curve: 'basis',
          nodeSpacing: 45,
          rankSpacing: 45
        }
      });
      isInitialized = true;
    } catch (e) {
      console.warn('Mermaid init error:', e);
    }
  }
};

onMounted(async () => {
  initMermaid();
  await nextTick();
  renderChart();
});

watch(() => props.chartText, async () => {
  await nextTick();
  renderChart();
});

const renderChart = async () => {
  if (!props.chartText || !props.chartText.trim() || !mermaidDiv.value) return;

  const code = props.chartText.trim();
  const id = `mermaid-render-${Date.now()}-${renderIdCounter++}`;

  try {
    loading.value = true;
    
    // Check syntax validity first to prevent red error flashes during live typing
    const isValid = await mermaid.parse(code).catch(() => false);
    if (!isValid) {
      loading.value = false;
      return; // Keep previous rendered valid diagram while typing incomplete syntax
    }

    const { svg } = await mermaid.render(id, code);
    if (mermaidDiv.value) {
      mermaidDiv.value.innerHTML = svg;
      renderedSvg.value = true;

      // Attach native SVG <title> tags to every node for clean mouse-hover tooltips
      const nodes = mermaidDiv.value.querySelectorAll('.node');
      nodes.forEach(node => {
        const fullText = node.textContent.trim();
        if (fullText && !node.querySelector('title')) {
          const titleEl = document.createElementNS('http://www.w3.org/2000/svg', 'title');
          titleEl.textContent = fullText;
          node.appendChild(titleEl);
        }
      });
    }
  } catch (e) {
    console.warn('Mermaid rendering skipped:', e);
  } finally {
    loading.value = false;
  }
};
</script>

<style scoped>
.mermaid-container {
  margin: 1.5rem 0;
  padding: 1.25rem;
  background: white;
  border-radius: 8px;
  border: 1px solid #e2e8f0;
}

.mermaid-body {
  position: relative;
  min-height: 120px;
  display: flex;
  justify-content: center;
  align-items: center;
}

.mermaid {
  display: flex;
  justify-content: center;
  overflow-x: auto;
  width: 100%;
}

.mermaid-loading {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  color: var(--text-muted);
  font-size: 0.9rem;
  padding: 1rem;
}

.spinner {
  width: 16px;
  height: 16px;
  border: 2px solid #cbd5e1;
  border-top-color: var(--primary);
  border-radius: 50%;
  animation: spin 0.6s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.mermaid-unavailable {
  margin: 1.5rem 0;
  padding: 1rem;
  background-color: #f8fafc;
  border-radius: 8px;
  text-align: center;
  color: #64748b;
  font-size: 0.9rem;
}
</style>
