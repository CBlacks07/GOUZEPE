/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{vue,js,ts}'],
  darkMode: ['class', '[data-theme="dark"]'],
  theme: {
    extend: {
      colors: {
        'gz-bg':     'var(--bg)',
        'gz-panel':  'var(--panel)',
        'gz-card':   'var(--card)',
        'gz-border': 'var(--border)',
        'gz-text':   'var(--text)',
        'gz-muted':  'var(--muted)',
        'gz-input':  'var(--input)',
        'gz-green':  'var(--green)',
        'gz-blue':   'var(--blue)',
        'gz-red':    'var(--red)',
        'gz-amber':  'var(--amber)',
      },
      fontFamily: {
        sans: ['var(--font-body)', 'Inter', 'system-ui', 'sans-serif'],
        title: ['var(--font-title)', 'Exo 2', 'system-ui', 'sans-serif'],
      },
      borderRadius: {
        card: '12px',
      },
      keyframes: {
        'winner-in': {
          from: { opacity: '0', transform: 'scale(0.9) translateY(-4px)' },
          to:   { opacity: '1', transform: 'none' },
        },
        'fade-in': {
          from: { opacity: '0' },
          to:   { opacity: '1' },
        },
        'slide-up': {
          from: { opacity: '0', transform: 'translateY(8px)' },
          to:   { opacity: '1', transform: 'translateY(0)' },
        },
      },
      animation: {
        'winner-in': 'winner-in 0.35s ease',
        'fade-in':   'fade-in 0.2s ease',
        'slide-up':  'slide-up 0.25s ease',
      },
    },
  },
  plugins: [],
}
