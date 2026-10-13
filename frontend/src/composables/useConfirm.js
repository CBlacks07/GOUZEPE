import { reactive } from 'vue'

/*
 * Boîte de confirmation de l'application (remplace window.confirm).
 *   const ok = await askConfirm({ title, message, confirmLabel, danger })
 *   const ok = await askConfirm('Message simple')
 * Retourne true si l'utilisateur confirme, false s'il annule (bouton, Échap ou clic à côté).
 */
const DEFAULTS = { title: '', message: '', confirmLabel: 'Confirmer', cancelLabel: 'Annuler', danger: false }

const state = reactive({ open: false, ...DEFAULTS })
let resolver = null

export function askConfirm(opts) {
  const o = typeof opts === 'string' ? { message: opts } : (opts || {})
  if (resolver) resolver(false)
  Object.assign(state, DEFAULTS, o, { open: true })
  return new Promise((resolve) => { resolver = resolve })
}

export function answerConfirm(value) {
  state.open = false
  const r = resolver
  resolver = null
  if (r) r(value)
}

export function useConfirm() {
  return { state, askConfirm, answerConfirm }
}
