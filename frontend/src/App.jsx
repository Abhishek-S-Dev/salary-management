import { useCallback, useEffect, useMemo, useState } from 'react'
import {
  createEmployee,
  createPayrollEntry,
  deleteEmployee,
  deletePayrollEntry,
  listEmployees,
  listPayrollEntries,
  updateEmployee,
} from './api'
import './App.css'

const money = new Intl.NumberFormat(undefined, {
  style: 'currency',
  currency: 'USD',
  maximumFractionDigits: 2,
})

const emptyEmployeeForm = {
  first_name: '',
  last_name: '',
  email: '',
  department: '',
  designation: '',
  base_salary: '',
}

function App() {
  const [employees, setEmployees] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)
  const [selectedId, setSelectedId] = useState(null)
  const [payrolls, setPayrolls] = useState([])
  const [employeeForm, setEmployeeForm] = useState(emptyEmployeeForm)
  const [editingId, setEditingId] = useState(null)
  const [payrollForm, setPayrollForm] = useState({
    period_year: new Date().getFullYear(),
    period_month: new Date().getMonth() + 1,
    gross_amount: '',
    deductions_amount: '0',
  })

  const refreshEmployees = useCallback(async () => {
    setError(null)
    const rows = await listEmployees()
    setEmployees(rows)
    return rows
  }, [])

  useEffect(() => {
    let cancelled = false
    ;(async () => {
      try {
        setLoading(true)
        await refreshEmployees()
      } catch (e) {
        if (!cancelled) setError(e.message)
      } finally {
        if (!cancelled) setLoading(false)
      }
    })()
    return () => {
      cancelled = true
    }
  }, [refreshEmployees])

  const selected = useMemo(
    () => employees.find((e) => String(e.id) === String(selectedId)) || null,
    [employees, selectedId],
  )

  const loadPayrolls = useCallback(async (employeeId) => {
    if (!employeeId) {
      setPayrolls([])
      return
    }
    const rows = await listPayrollEntries(employeeId)
    setPayrolls(rows)
  }, [])

  useEffect(() => {
    if (!selectedId) {
      setPayrolls([])
      return
    }
    let cancelled = false
    ;(async () => {
      try {
        await loadPayrolls(selectedId)
      } catch (e) {
        if (!cancelled) setError(e.message)
      }
    })()
    return () => {
      cancelled = true
    }
  }, [selectedId, loadPayrolls])

  async function handleSubmitEmployee(e) {
    e.preventDefault()
    setError(null)
    const payload = {
      ...employeeForm,
      base_salary: Number(employeeForm.base_salary),
    }
    try {
      if (editingId) {
        await updateEmployee(editingId, payload)
      } else {
        await createEmployee(payload)
      }
      setEmployeeForm(emptyEmployeeForm)
      setEditingId(null)
      await refreshEmployees()
    } catch (err) {
      setError(err.message)
    }
  }

  async function handleDeleteEmployee(id) {
    if (!window.confirm('Remove this employee and their payroll history?')) return
    setError(null)
    try {
      await deleteEmployee(id)
      if (String(selectedId) === String(id)) setSelectedId(null)
      await refreshEmployees()
    } catch (err) {
      setError(err.message)
    }
  }

  function startEdit(emp) {
    setEditingId(emp.id)
    setEmployeeForm({
      first_name: emp.first_name,
      last_name: emp.last_name,
      email: emp.email,
      department: emp.department || '',
      designation: emp.designation || '',
      base_salary: String(emp.base_salary),
    })
    window.scrollTo({ top: 0, behavior: 'smooth' })
  }

  async function handleSubmitPayroll(e) {
    e.preventDefault()
    if (!selectedId) return
    setError(null)
    try {
      await createPayrollEntry(selectedId, {
        period_year: Number(payrollForm.period_year),
        period_month: Number(payrollForm.period_month),
        gross_amount: Number(payrollForm.gross_amount),
        deductions_amount: Number(payrollForm.deductions_amount || 0),
      })
      setPayrollForm((p) => ({
        ...p,
        gross_amount: '',
        deductions_amount: '0',
      }))
      await loadPayrolls(selectedId)
    } catch (err) {
      setError(err.message)
    }
  }

  async function handleDeletePayroll(entryId) {
    if (!window.confirm('Delete this payroll entry?')) return
    setError(null)
    try {
      await deletePayrollEntry(selectedId, entryId)
      await loadPayrolls(selectedId)
    } catch (err) {
      setError(err.message)
    }
  }

  return (
    <div className="layout">
      <header className="topbar">
        <div>
          <p className="eyebrow">Rails API · React · Postgres</p>
          <h1>Salary management</h1>
          <p className="lede">
            Maintain employees and monthly payroll (gross, deductions, net pay).
          </p>
        </div>
        <div className="pill-row">
          <span className="pill">API: /api/v1</span>
          <span className="pill ghost">Vite proxy → Rails</span>
        </div>
      </header>

      {error ? (
        <div className="banner error" role="alert">
          {error}
        </div>
      ) : null}

      <main className="grid">
        <section className="card">
          <div className="card-head">
            <h2>{editingId ? 'Edit employee' : 'New employee'}</h2>
            {editingId ? (
              <button
                type="button"
                className="btn ghost"
                onClick={() => {
                  setEditingId(null)
                  setEmployeeForm(emptyEmployeeForm)
                }}
              >
                Cancel edit
              </button>
            ) : null}
          </div>
          <form className="form" onSubmit={handleSubmitEmployee}>
            <div className="field-grid">
              <label>
                First name
                <input
                  required
                  value={employeeForm.first_name}
                  onChange={(ev) =>
                    setEmployeeForm((f) => ({ ...f, first_name: ev.target.value }))
                  }
                />
              </label>
              <label>
                Last name
                <input
                  required
                  value={employeeForm.last_name}
                  onChange={(ev) =>
                    setEmployeeForm((f) => ({ ...f, last_name: ev.target.value }))
                  }
                />
              </label>
              <label className="field-span-2">
                Email
                <input
                  required
                  type="email"
                  value={employeeForm.email}
                  onChange={(ev) =>
                    setEmployeeForm((f) => ({ ...f, email: ev.target.value }))
                  }
                />
              </label>
              <label>
                Department
                <input
                  value={employeeForm.department}
                  onChange={(ev) =>
                    setEmployeeForm((f) => ({ ...f, department: ev.target.value }))
                  }
                />
              </label>
              <label>
                Designation
                <input
                  value={employeeForm.designation}
                  onChange={(ev) =>
                    setEmployeeForm((f) => ({ ...f, designation: ev.target.value }))
                  }
                />
              </label>
              <label className="field-span-2">
                Base salary (annual reference)
                <input
                  required
                  min="0"
                  step="0.01"
                  type="number"
                  value={employeeForm.base_salary}
                  onChange={(ev) =>
                    setEmployeeForm((f) => ({ ...f, base_salary: ev.target.value }))
                  }
                />
              </label>
            </div>
            <button className="btn primary" type="submit">
              {editingId ? 'Save changes' : 'Create employee'}
            </button>
          </form>
        </section>

        <section className="card">
          <div className="card-head">
            <h2>Employees</h2>
            <button className="btn ghost" type="button" onClick={() => refreshEmployees()}>
              Refresh
            </button>
          </div>
          {loading ? (
            <p className="muted">Loading roster…</p>
          ) : employees.length === 0 ? (
            <p className="muted">No employees yet. Add one on the left.</p>
          ) : (
            <div className="table-wrap">
              <table className="table">
                <thead>
                  <tr>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Base</th>
                    <th />
                  </tr>
                </thead>
                <tbody>
                  {employees.map((emp) => (
                    <tr
                      key={emp.id}
                      className={String(selectedId) === String(emp.id) ? 'selected' : ''}
                    >
                      <td>
                        <button
                          type="button"
                          className="linkish"
                          onClick={() => setSelectedId(emp.id)}
                        >
                          {emp.first_name} {emp.last_name}
                        </button>
                      </td>
                      <td>{emp.email}</td>
                      <td>{money.format(Number(emp.base_salary))}</td>
                      <td className="actions">
                        <button type="button" className="btn tiny" onClick={() => startEdit(emp)}>
                          Edit
                        </button>
                        <button
                          type="button"
                          className="btn tiny danger"
                          onClick={() => handleDeleteEmployee(emp.id)}
                        >
                          Delete
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </section>

        <section className="card wide-card">
          <div className="card-head">
            <h2>Payroll entries</h2>
            {selected ? (
              <p className="muted tight">
                For <strong>{selected.first_name}</strong> · base{' '}
                {money.format(Number(selected.base_salary))}
              </p>
            ) : (
              <p className="muted tight">Select an employee to manage payroll.</p>
            )}
          </div>

          {selected ? (
            <>
              <form className="form inline" onSubmit={handleSubmitPayroll}>
                <label>
                  Year
                  <input
                    type="number"
                    min="2000"
                    max="2099"
                    required
                    value={payrollForm.period_year}
                    onChange={(ev) =>
                      setPayrollForm((p) => ({ ...p, period_year: ev.target.value }))
                    }
                  />
                </label>
                <label>
                  Month
                  <input
                    type="number"
                    min="1"
                    max="12"
                    required
                    value={payrollForm.period_month}
                    onChange={(ev) =>
                      setPayrollForm((p) => ({ ...p, period_month: ev.target.value }))
                    }
                  />
                </label>
                <label>
                  Gross
                  <input
                    type="number"
                    min="0"
                    step="0.01"
                    required
                    value={payrollForm.gross_amount}
                    onChange={(ev) =>
                      setPayrollForm((p) => ({ ...p, gross_amount: ev.target.value }))
                    }
                  />
                </label>
                <label>
                  Deductions
                  <input
                    type="number"
                    min="0"
                    step="0.01"
                    value={payrollForm.deductions_amount}
                    onChange={(ev) =>
                      setPayrollForm((p) => ({ ...p, deductions_amount: ev.target.value }))
                    }
                  />
                </label>
                <button className="btn primary" type="submit">
                  Add payroll
                </button>
              </form>

              <div className="table-wrap">
                <table className="table">
                  <thead>
                    <tr>
                      <th>Period</th>
                      <th>Gross</th>
                      <th>Deductions</th>
                      <th>Net</th>
                      <th />
                    </tr>
                  </thead>
                  <tbody>
                    {payrolls.length === 0 ? (
                      <tr>
                        <td colSpan={5} className="muted">
                          No payroll rows yet.
                        </td>
                      </tr>
                    ) : (
                      payrolls.map((row) => (
                        <tr key={row.id}>
                          <td>
                            {row.period_year}-{String(row.period_month).padStart(2, '0')}
                          </td>
                          <td>{money.format(Number(row.gross_amount))}</td>
                          <td>{money.format(Number(row.deductions_amount))}</td>
                          <td>
                            <strong>{money.format(Number(row.net_amount))}</strong>
                          </td>
                          <td className="actions">
                            <button
                              type="button"
                              className="btn tiny danger"
                              onClick={() => handleDeletePayroll(row.id)}
                            >
                              Delete
                            </button>
                          </td>
                        </tr>
                      ))
                    )}
                  </tbody>
                </table>
              </div>
            </>
          ) : null}
        </section>
      </main>
    </div>
  )
}

export default App
