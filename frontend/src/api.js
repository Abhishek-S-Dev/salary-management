const prefix = import.meta.env.VITE_API_PREFIX ?? ''

function buildQuery(params) {
  const qs = new URLSearchParams()
  Object.entries(params).forEach(([key, value]) => {
    if (value === undefined || value === null || value === '') return
    qs.set(key, String(value))
  })
  const s = qs.toString()
  return s ? `?${s}` : ''
}

async function request(path, options = {}) {
  const url = `${prefix}${path}`
  const headers = {
    Accept: 'application/json',
    ...(options.headers || {}),
  }
  if (options.body && !headers['Content-Type']) {
    headers['Content-Type'] = 'application/json'
  }

  const res = await fetch(url, { ...options, headers })
  const text = await res.text()
  let data = null
  if (text) {
    try {
      data = JSON.parse(text)
    } catch {
      data = text
    }
  }

  if (!res.ok) {
    const message =
      (typeof data === 'object' && data?.errors?.join?.(', ')) ||
      (typeof data === 'object' && data?.error) ||
      res.statusText ||
      'Request failed'
    throw new Error(message)
  }

  return data
}

export function listEmployees(opts = {}) {
  const { page = 1, per_page = 20, q = '' } = opts
  return request(`/api/v1/employees${buildQuery({ page, per_page, q })}`)
}

export function listDepartments() {
  return request('/api/v1/departments')
}

export async function fetchHealth() {
  return request('/api/v1/health')
}

export async function downloadEmployeesCsv() {
  const url = `${prefix}/api/v1/employees/export`
  const res = await fetch(url, { headers: { Accept: 'text/csv' } })
  if (!res.ok) {
    throw new Error(res.statusText || 'Export failed')
  }
  const blob = await res.blob()
  const objectUrl = URL.createObjectURL(blob)
  const anchor = document.createElement('a')
  anchor.href = objectUrl
  anchor.download = `employees-${new Date().toISOString().slice(0, 10)}.csv`
  anchor.click()
  URL.revokeObjectURL(objectUrl)
}

export function createEmployee(payload) {
  return request('/api/v1/employees', {
    method: 'POST',
    body: JSON.stringify({ employee: payload }),
  })
}

export function updateEmployee(id, payload) {
  return request(`/api/v1/employees/${id}`, {
    method: 'PATCH',
    body: JSON.stringify({ employee: payload }),
  })
}

export function deleteEmployee(id) {
  return request(`/api/v1/employees/${id}`, { method: 'DELETE' })
}

export function listPayrollEntries(employeeId) {
  return request(`/api/v1/employees/${employeeId}/payroll_entries`)
}

export function createPayrollEntry(employeeId, payload) {
  return request(`/api/v1/employees/${employeeId}/payroll_entries`, {
    method: 'POST',
    body: JSON.stringify({ payroll_entry: payload }),
  })
}

export function deletePayrollEntry(employeeId, entryId) {
  return request(`/api/v1/employees/${employeeId}/payroll_entries/${entryId}`, {
    method: 'DELETE',
  })
}
