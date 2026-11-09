import { useId, useState } from 'react'
import './DataTable.css'

export default function DataTable({
  columns,
  rows,
  rowKey,
  filterLabel = 'Filter',
  emptyMessage = 'No rows to show.',
  initialSort = null, // optional column key the table starts sorted by
}) {
  const filterId = useId() // several tables can share a page, so ids must be unique
  const [filter, setFilter] = useState('')
  const [sort, setSort] = useState({ key: initialSort, dir: 'asc' })

  const textOf = (col, row) => (col.format ? col.format(row) : String(row[col.key] ?? ''))
  const isSortable = (col) => col.sortable !== false && (!col.render || Boolean(col.sortValue))
  const isSearchable = (col) => !col.render

  // 1. filter
  const query = filter.trim().toLowerCase()
  let visibleRows = query
    ? rows.filter((row) =>
        columns.some((c) => isSearchable(c) && textOf(c, row).toLowerCase().includes(query))
      )
    : rows

  // 2. sort (empty values always go last)
  const sortCol = columns.find((c) => c.key === sort.key)
  if (sortCol) {
    const get = sortCol.sortValue ?? ((row) => row[sortCol.key])
    const direction = sort.dir === 'asc' ? 1 : -1
    visibleRows = [...visibleRows].sort((a, b) => {
      const x = get(a)
      const y = get(b)
      if (x == null && y == null) return 0
      if (x == null) return 1
      if (y == null) return -1
      if (typeof x === 'number' && typeof y === 'number') return (x - y) * direction
      return String(x).localeCompare(String(y), undefined, { numeric: true, sensitivity: 'base' }) * direction
    })
  }

  function toggleSort(key) {
    setSort((prev) =>
      prev.key === key ? { key, dir: prev.dir === 'asc' ? 'desc' : 'asc' } : { key, dir: 'asc' }
    )
  }

  if (rows.length === 0) {
    return <p>{emptyMessage}</p>
  }

  return (
    <div className="dt">
      <div className="dt-filter">
        <label htmlFor={filterId}>{filterLabel}</label>
        <input
          id={filterId}
          type="search"
          value={filter}
          onChange={(e) => setFilter(e.target.value)}
        />
        <p className="dt-count" aria-live="polite">
          Showing {visibleRows.length} of {rows.length}
        </p>
      </div>

      <div className="dt-wrap">
        <table className="dt-table">
          <thead>
            <tr>
              {columns.map((c) => {
                const active = sort.key === c.key
                const label = c.hideLabel ? <span className="dt-sr-only">{c.label}</span> : c.label
                return (
                  <th
                    key={c.key}
                    scope="col"
                    className={c.align === 'right' ? 'dt-num' : undefined}
                    aria-sort={active ? (sort.dir === 'asc' ? 'ascending' : 'descending') : undefined}
                  >
                    {isSortable(c) ? (
                      <button type="button" className="dt-sort" onClick={() => toggleSort(c.key)}>
                        {label}
                        <span className="dt-arrow" aria-hidden="true">
                          {active ? (sort.dir === 'asc' ? '▲' : '▼') : '⇅'}
                        </span>
                      </button>
                    ) : (
                      label
                    )}
                  </th>
                )
              })}
            </tr>
          </thead>
          <tbody>
            {visibleRows.length === 0 ? (
              <tr>
                <td colSpan={columns.length}>No rows match “{filter}”.</td>
              </tr>
            ) : (
              visibleRows.map((row) => (
                <tr key={rowKey(row)}>
                  {columns.map((c) => (
                    <td key={c.key} className={c.align === 'right' ? 'dt-num' : undefined}>
                      {c.render ? c.render(row) : textOf(c, row)}
                    </td>
                  ))}
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  )
}
