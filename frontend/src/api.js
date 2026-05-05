const prefix = import.meta.env.VITE_API_PREFIX ?? ''

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

export function listEmployees() {
  return request('/api/v1/employees')
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
