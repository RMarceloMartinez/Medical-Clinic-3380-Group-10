// Small line icons drawn with SVG, so the site needs no icon library.
// Usage: <Icon name="calendar" size={20} />
// Each icon is a list of shapes on a 24x24 grid. "currentColor" means the
// icon takes the text color of whatever it sits in, so CSS can recolor it.
const ICONS = {
  heartPulse: (
    <>
      <path d="M12 20s-7.5-4.6-9-9.5C2 7 4.2 4.5 7 4.5c2 0 3.6 1.2 5 3 1.4-1.8 3-3 5-3 2.8 0 5 2.5 4 6-1.5 4.9-9 9.5-9 9.5z" />
      <path d="M5 12h3l2-3 3 6 2-3h4" />
    </>
  ),
  home: (
    <>
      <path d="M3 11l9-7 9 7" />
      <path d="M5 10v10h14V10" />
      <path d="M10 20v-6h4v6" />
    </>
  ),
  calendar: (
    <>
      <rect x="3" y="5" width="18" height="16" rx="2" />
      <path d="M16 3v4M8 3v4M3 10h18" />
    </>
  ),
  calendarPlus: (
    <>
      <rect x="3" y="5" width="18" height="16" rx="2" />
      <path d="M16 3v4M8 3v4M3 10h18M12 13v5M9.5 15.5h5" />
    </>
  ),
  users: (
    <>
      <circle cx="9" cy="8" r="3.5" />
      <path d="M2.5 20c0-3.6 2.9-6 6.5-6s6.5 2.4 6.5 6" />
      <path d="M16 4.5a3.5 3.5 0 0 1 0 7M18 14c2.2.5 3.5 2.7 3.5 6" />
    </>
  ),
  receipt: (
    <>
      <path d="M6 3h12v18l-3-2-3 2-3-2-3 2z" />
      <path d="M9 8h6M9 12h6M9 16h3" />
    </>
  ),
  wallet: (
    <>
      <circle cx="12" cy="12" r="9" />
      <path d="M15 9.5c-.5-1-1.6-1.5-3-1.5-1.7 0-3 .9-3 2s1.3 1.7 3 2 3 .9 3 2-1.3 2-3 2c-1.4 0-2.5-.5-3-1.5M12 6.5v11" />
    </>
  ),
  search: (
    <>
      <circle cx="11" cy="11" r="7" />
      <path d="M20 20l-4-4" />
    </>
  ),
  chart: <path d="M4 20V10M10 20V4M16 20v-7M3 20h18" />,
  logout: <path d="M9 4H5v16h4M16 16l4-4-4-4M20 12H9" />,
  clock: (
    <>
      <circle cx="12" cy="12" r="9" />
      <path d="M12 7v5l3 2" />
    </>
  ),
  mapPin: (
    <>
      <path d="M12 21s-7-6.2-7-11a7 7 0 0 1 14 0c0 4.8-7 11-7 11z" />
      <circle cx="12" cy="10" r="2.5" />
    </>
  ),
  stethoscope: (
    <>
      <path d="M6 3H5v6a5 5 0 0 0 10 0V3h-1" />
      <path d="M10 14v1a5 5 0 0 0 10 0v-3" />
      <circle cx="20" cy="10" r="2" />
    </>
  ),
  user: (
    <>
      <circle cx="12" cy="8" r="4" />
      <path d="M4 21c0-4 3.6-7 8-7s8 3 8 7" />
    </>
  ),
  arrowRight: <path d="M5 12h14M13 6l6 6-6 6" />,
}

export default function Icon({ name, size = 20 }) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
    >
      {ICONS[name]}
    </svg>
  )
}
