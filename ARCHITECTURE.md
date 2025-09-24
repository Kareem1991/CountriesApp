# Clean Architecture 

## 🏗️ **Architecture Overview**


```
App/
├── Shared/                    # Reusable Components
│   ├── LoadingState.swift     # Generic loading states
│   ├── LoadingView.swift      # Reusable loading UI
│   └── ErrorView.swift        # Reusable error UI
├── Services/                  # Single Responsibility Services
│   ├── LocationService.swift  # Location handling only
│   ├── StorageService.swift   # Data persistence only
│   ├── SearchService.swift    # Search functionality only
│   └── CountryService.swift   # Country operations only
└── Modules/Countries/         # Feature Module
    ├── Domain/               # Business Logic
    ├── Data/                 # Data Access
    └── Presentation/         # UI Layer
```

