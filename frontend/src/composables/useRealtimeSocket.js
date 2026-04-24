let socket = null
let connectPromise = null

function resolveApiBase() {
  const fromStorage = (typeof localStorage !== 'undefined' && localStorage.getItem('efoot.api')) || ''
  if (fromStorage) return fromStorage
  if (typeof window !== 'undefined') return `${window.location.protocol}//${window.location.hostname}:3005`
  return 'http://localhost:3005'
}

function loadSocketIoScript() {
  if (typeof window === 'undefined') return Promise.reject(new Error('window unavailable'))
  if (window.io) return Promise.resolve(window.io)

  const existing = document.querySelector('script[data-gz-socketio="1"]')
  if (existing) {
    return new Promise((resolve, reject) => {
      existing.addEventListener('load', () => resolve(window.io), { once: true })
      existing.addEventListener('error', () => reject(new Error('socket.io client load failed')), { once: true })
    })
  }

  return new Promise((resolve, reject) => {
    const script = document.createElement('script')
    script.src = `${resolveApiBase().replace(/\/+$/, '')}/socket.io/socket.io.js`
    script.async = true
    script.defer = true
    script.setAttribute('data-gz-socketio', '1')
    script.onload = () => {
      if (!window.io) return reject(new Error('socket.io global not found'))
      resolve(window.io)
    }
    script.onerror = () => reject(new Error('socket.io client load failed'))
    document.head.appendChild(script)
  })
}

export async function ensureRealtimeSocket() {
  if (socket) return socket
  if (connectPromise) return connectPromise

  connectPromise = (async () => {
    const ioFactory = await loadSocketIoScript()
    const endpoint = resolveApiBase()
    socket = ioFactory(endpoint, {
      transports: ['websocket', 'polling'],
      reconnection: true,
      reconnectionAttempts: Infinity,
      reconnectionDelay: 800,
      reconnectionDelayMax: 5000,
      timeout: 12000,
    })
    return socket
  })()

  try {
    return await connectPromise
  } finally {
    connectPromise = null
  }
}

export async function joinRealtimeRoom(room) {
  if (!room) return
  const s = await ensureRealtimeSocket()
  s.emit('join', { room })
}

export async function leaveRealtimeRoom(room) {
  if (!room) return
  const s = await ensureRealtimeSocket()
  s.emit('leave', { room })
}

export function onRealtimeEvent(eventName, handler) {
  let disposed = false
  let attachedSocket = null

  ensureRealtimeSocket()
    .then((s) => {
      if (disposed) return
      attachedSocket = s
      s.on(eventName, handler)
    })
    .catch(() => {})

  return () => {
    disposed = true
    if (attachedSocket) attachedSocket.off(eventName, handler)
  }
}

