// Shared frame for both portals: header (who is logged in + Log out),
// a menu with only the pages this user may open, then the current page.
export default function Layout({ title, account, items, current, onSelect, onLogout, children }) {
  return (
    <div className="dashboard">
      <header className="app-header">
        <div>
          <h1 className="app-title">{title}</h1>
          <p className="app-user">
            Signed in as <strong>{account.username}</strong> ({account.role})
          </p>
        </div>
        <button type="button" className="logout-button" onClick={onLogout}>
          Log out
        </button>
      </header>

      <nav className="dashboard-nav">
        {items.map((item) => (
          <button
            key={item.key}
            type="button"
            className={item.key === current ? 'active' : ''}
            onClick={() => onSelect(item.key)}
          >
            {item.label}
          </button>
        ))}
      </nav>

      <main className="page">{children}</main>
    </div>
  )
}
