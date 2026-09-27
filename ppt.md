# Project Resilience: Autonomous Sovereign Healthcare Supply Chain & Predictive Redistribution Network

---

## Executive Summary & Problem-Solution Overview

### The Real-World Crisis: Rural Healthcare Supply Chains in India
Public healthcare delivery across Primary Health Centres (PHCs) in India faces systemic logistical failure:
* **The Stockout Paradox:** While central medical store depots (CMSDs) report adequate buffer stocks, peripheral PHCs experience severe stockouts of life-saving anti-venoms, insulin, maternal oxytocics, and rabies vaccines.
* **Bullwhip Effect & Artificial Surpluses:** One PHC may exhaust life-saving rabies vaccines during a localized spike, while an adjacent PHC 18 km away sits on 300 expiring vials due to rigid, bureaucratic batch-allocation quotas.
* **Information Blackout & Lag:** Stock levels are compiled via manual end-of-month registers. By the time a stockout is reported up the bureaucratic hierarchy, patient mortality or distress referral has already occurred.
* **Cold-Chain Degradation & Pilferage:** 28% of temperature-sensitive biologics suffer cold-chain failure or undocumented leakage during intermediate transit between facilities.
* **Data Sovereignty Constraints:** Strict patient privacy and cross-district health governance laws prohibit pooling raw patient-level dispensing records into a centralized cloud database.

### What We Built: Project Resilience
Project Resilience is a closed-loop, privacy-preserving, AI-orchestrated healthcare supply chain platform engineered for district health administrations and grassroots PHCs. 

It autonomously detects, forecasts, prevents, and resolves rural medicine shortages in real time through:
1. **Holt-Winters Triple Exponential Smoothing** at the edge for 7-day predictive stockout forecasting capturing weekly rural Outpatient Department (OPD) market cycles.
2. **Sovereign Federated Learning (Flower FedAvg)** across isolated district data silos—training district demand forecasting models collaboratively without moving a single raw dispensing record.
3. **Operations Research (OR) Redistribution Optimizer** utilizing the Hungarian Algorithm (`scipy.optimize.linear_sum_assignment`) with Haversine/OSRM routing matrices to match surplus PHCs to critical deficit PHCs within a strict 45 km cold-chain perimeter.
4. **Cryptographically Verified Cold-Chain Handover** with automated 6-digit OTP verification, live driver dispatch tracking, and atomic bidirectional inventory adjustments.
5. **Cross-Platform Responsive Command Console** built with Flutter 3 (Android, iOS, Web, Desktop) backed by an asynchronous high-throughput FastAPI engine.

---

## System Architecture & Component Topology

```
+-----------------------------------------------------------------------------------+
|                           FRONTEND: FLUTTER 3.12 (DART)                           |
|  Material 3 Design System | flutter_map + latlong2 | Multi-Role State Architecture|
|                                                                                   |
|  [PHC Staff Mobile/Web]     [District DMO Command]       [Logistics Driver Portal]|
|  - Realtime Dispensing       - Sovereign Federated FL     - Route Navigation      |
|  - Rapid Stock Entry         - Hungarian OR Optimizer     - Cold-chain OTP Handover|
|  - Emergency Requisition     - Outbreak Simulators        - Delivery Signoff      |
+------------------------------------------+----------------------------------------+
                                           | HTTPS / JSON REST
                                           v
+-----------------------------------------------------------------------------------+
|                           BACKEND: FASTAPI (PYTHON 3.10+)                         |
|  Uvicorn ASGI | Pydantic v2 Contracts | SQLAlchemy 2.0 ORM | RBAC Middleware     |
|                                                                                   |
|  +---------------------+  +------------------------+  +------------------------+  |
|  |   ANALYTICS ENGINE  |  |   FEDERATED LEARNING   |  |  OPTIMIZATION ENGINE   |  |
|  | - Holt-Winters ETS  |  | - Flower (flwr) FedAvg |  | - Hungarian Algorithm  |  |
|  | - Polynomial Fallback| | - 5 District Silos     |  | - Haversine/OSRM Matrix|  |
|  | - OPD Weekly Cycles |  | - Privacy Weights Agg  |  | - Max Radius: 45 km    |  |
|  +---------------------+  +------------------------+  +------------------------+  |
+------------------------------------------+----------------------------------------+
                                           | Database Engine
                                           v
+-----------------------------------------------------------------------------------+
|                        DATA PERSISTENCE & GEOSPATIAL STORAGE                      |
|  SQLite (Dev) / PostgreSQL 15+ (Production)                                       |
|  - 8 Relational Tables (Districts, PHCs, Details, Inventory, Logs, Transfers, etc)|
|  - Geo-Coordinates (Lat/Lon) with Haversine Spatial Indexing                      |
+-----------------------------------------------------------------------------------+
```

---

## Core Technologies & Implementation Rationale

### Frontend Stack: Flutter 3.12 & Dart
| Component | Selection | Justification / Architectural Rationale |
| :--- | :--- | :--- |
| **Framework** | Flutter 3.12 (Dart ^3.12.0) | Single codebase compilation across Android APK (for rural PHC tablets and driver mobile phones) and responsive Web/Desktop (for District Medical Officer command rooms). |
| **UI Design System** | Material 3 with Custom Tokens | Modern tactile glassmorphism, responsive navigation rail for wide displays, bottom bar for mobile, customized high-contrast telemetry charts. |
| **Mapping & GIS** | `flutter_map` ^6.0.0 + `latlong2` | Fully offline-capable OpenStreetMap vector/raster tile rendering without expensive proprietary API dependencies (Google Maps API costs eliminated). |
| **Networking** | `http` ^1.2.0 | Lightweight HTTP client with custom interceptors for resilient payload retries, dynamic backend base-URL switching, and timeout fallback. |
| **State Management** | Modular `StatefulWidget` + Service Locators | Zero-dependency, performant state lifecycle without bloated third-party state managers; prevents runtime crashes on low-spec government tablets. |

### Backend Stack: FastAPI & Scientific Python
| Component | Selection | Justification / Architectural Rationale |
| :--- | :--- | :--- |
| **Web Framework** | FastAPI (ASGI on Uvicorn) | Asynchronous non-blocking I/O handling high concurrency; native Pydantic v2 validation enforces strict runtime data integrity on medical data. |
| **Data Layer** | SQLAlchemy 2.0 ORM | Decoupled persistence model allowing zero-code migration between SQLite (offline/local pilot) and PostgreSQL 15 (state-scale deployment). |
| **Forecasting** | `statsmodels` (Holt-Winters) | Captures trend and additive 7-day seasonality reflecting weekly rural market and primary health OPD peak days. |
| **Optimization** | `scipy.optimize.linear_sum_assignment` | Polynomial-time $O(N^3)$ modified Hungarian algorithm solving bipartite allocation matching deficit PHCs to surplus donors with zero heuristic drift. |
| **Federated ML** | Flower Framework (`flwr` >=1.4.0) | Sovereign edge ML aggregation. Prevents centralizing patient/dispensing logs by computing federated model weight averages ($W_{global} = \sum \frac{N_k}{N} W_k$). |
| **Routing Math** | Haversine + OSRM Integration | Pure math geodesic distance calculations as an instant fallback when external routing servers encounter network blackouts. |

---

## Detailed System Capabilities: How We Solved Each Problem

### 1. 7-Day Predictive Stockout Forecasting (Edge AI)
* **The Challenge:** Raw historical consumption does not follow a simple linear average; rural clinics experience heavy spikes on weekly market days (haat days) and seasonal drops during harvest.
* **Our Implementation:**
  * **Primary Model:** Holt-Winters Exponential Smoothing (Triple Exponential Smoothing) with additive trend and additive seasonality ($m=7$).
  * **Seasonality Parameter:** `seasonal_periods=7` models the cyclical weekly rhythm of rural primary healthcare visits.
  * **Fallback Chain:** 
    * If data points are insufficient for seasonal decomposition ($N < 14$), the system shifts automatically to **Recency-Weighted Polynomial Regression**.
    * If $N < 5$, it degrades gracefully to a **Variance-Adjusted Run-Rate Moving Average**.
  * **Stockout Threshold:** Calculates "Days of Cover Remaining":
    $$\text{Days of Cover} = \frac{\text{Current Usable Physical Stock}}{\text{Forecasted Daily Demand}}$$
    * $\le 3\text{ Days}$: **Critical Deficit Flag (Red)** — triggers automated redistribution candidacy.
    * $3\text{ to }5\text{ Days}$: **Warning State (Amber)** — flags local requisition.
    * $\ge 5\text{ Days}$ with excess: **Surplus Donor Candidate (Green)**.

### 2. Sovereign Federated Learning Across District Silos
* **The Challenge:** Medical regulations prohibit sharing patient treatment histories across district boundaries or centralizing sensitive epidemiology data on public cloud servers.
* **Our Implementation:**
  * Configured independent localized client nodes representing individual districts (e.g., Khammam, Nalgonda, Warangal, Rangareddy, Medak).
  * Each district trains a local neural network/regression model using only its internal dispensing history.
  * **Aggregation Protocol:** The central aggregator uses Federated Averaging (FedAvg):
    $$W_{global} = \sum_{k=1}^{K} \frac{n_k}{n} W_k$$
  * Only gradient weights and bias matrices are transmitted over encrypted TLS. Raw patient records, local timestamps, and PHC identifiers never leave the district boundary.
  * Provides global epidemiological forecasting intelligence to remote clinics without compromising data governance.

### 3. Operations Research Redistribution Optimizer (Hungarian Algorithm)
* **The Challenge:** Emergency supply imbalances must be resolved between nearby facilities without causing a secondary stockout at the donor facility, and while respecting strict cold-chain transport perimeters.
* **Our Implementation:**
  * **Step 1: Inventory Categorization**
    * Shortage Cluster: Any PHC with $\text{Days of Cover} \le 3.0$.
    * Surplus Cluster: Any PHC with $\text{Days of Cover} \ge 5.0$ and absolute excess units $> 20$.
  * **Step 2: Distance & Feasibility Filtering**
    * Calculates geodesic Haversine distance matrix between all Deficit-Surplus pairs.
    * Enforces cold-chain maximum transit radius constraint:
      $$D(i, j) \le 45\text{ km}$$
  * **Step 3: Cost Matrix Formulation**
    * Cost function combines distance penalty, transport time, and urgency penalty:
      $$C_{ij} = \alpha \cdot D_{ij} + \beta \cdot (10 - \text{DaysRemaining}_i)$$
  * **Step 4: Optimal Matching**
    * Solves the balanced assignment problem using `scipy.optimize.linear_sum_assignment`.
    * Yields the mathematically minimal travel time and zero-waste transfer proposal.
  * **Safety Margin Guarantee:** The algorithm caps the donation volume so the donor PHC retains at least $5.0\text{ days}$ of autonomous buffer.

### 4. Cold-Chain Handover & Cryptographic Chain of Custody
* **The Challenge:** Transferred medicines frequently get stolen, misplaced, or exposed to ambient heat without documented accountability.
* **Our Implementation:**
  * **Proposal State:** Transfer directive created by AI; visible to District Medical Officer.
  * **Approval State:** DMO signs off on redistribution directive; automated push alert to logistics dispatch.
  * **In-Transit State:** Driver accepts task in portal. System cryptographically generates a secure, randomized 6-digit One-Time Password (OTP) linked to the transfer session ID.
  * **Completed State:** Upon physical delivery at the receiving PHC, receiving staff inspect the cold-chain storage logger and enter the driver's OTP into their terminal.
  * **Atomic Transaction Execution:**
    ```
    BEGIN TRANSACTION;
      UPDATE inventory SET quantity = quantity - X WHERE phc_id = donor_id;
      UPDATE inventory SET quantity = quantity + X WHERE phc_id = receiver_id;
      UPDATE transfers SET status = 'completed', delivery_timestamp = NOW() WHERE id = transfer_id;
    COMMIT;
    ```
    Guarantees zero ghost inventory and 100% auditable chain-of-custody.

---

## Database Architecture & Relational Schema

The backend uses a normalized relational architecture across 8 core entities:

```
+-------------------------------------------------------------------------------------+
|                                 RELATIONAL SCHEMA                                   |
+-------------------------------------------------------------------------------------+

  districts
  +------------------+---------+
  | id               | INTEGER | (PK)
  | name             | VARCHAR | Unique district name (e.g., Khammam)
  | state            | VARCHAR | State jurisdiction (e.g., Telangana)
  +------------------+---------+
         |
         | 1:N
         v
  phcs
  +------------------+---------+
  | id               | INTEGER | (PK)
  | name             | VARCHAR | PHC facility name
  | district_id      | INTEGER | (FK -> districts.id)
  | latitude         | FLOAT   | WGS84 Latitude coordinate
  | longitude        | FLOAT   | WGS84 Longitude coordinate
  | type             | VARCHAR | 24x7 PHC, Sub-Centre, CHC
  +------------------+---------+
         |
         +--------------------+---------------------+
         | 1:1                | 1:N                 | 1:N
         v                    v                     v
  phc_details          inventory             dispensing_logs
  +-----------------+  +------------------+  +------------------+
  | phc_id (PK, FK) |  | id          (PK) |  | id          (PK) |
  | cold_chain_cap  |  | phc_id      (FK) |  | phc_id      (FK) |
  | current_power   |  | medicine_id (FK) |  | medicine_id (FK) |
  | active_staff    |  | quantity         |  | quantity_dispensed|
  | distance_to_hub |  | batch_number     |  | timestamp        |
  +-----------------+  | expiry_date      |  | patient_category |
                       | reorder_level    |  +------------------+
                       +------------------+
                                |
                                | References
                                v
  medicines              transfers
  +------------------+   +------------------------------------+
  | id          (PK) |   | id                            (PK) |
  | code             |   | source_phc_id                 (FK) |
  | name             |   | destination_phc_id            (FK) |
  | category         |   | medicine_id                   (FK) |
  | unit             |   | quantity_transferred               |
  | min_temp_celsius |   | distance_km                        |
  | max_temp_celsius |   | status (proposed/approved/transit) |
  +------------------+   | otp_code                           |
                         | driver_id                     (FK) |
                         | created_at / completed_at          |
                         +------------------------------------+
```

---

## API Specifications & Network Contracts

Project Resilience exposes 19 fully typed REST endpoints:

### Authentication & Access
* `POST /api/auth/login` — Authenticates credentials, returns JWT bearer token and user role profile.
* `GET /api/auth/me` — Validates active token session and permissions.

### Primary Health Centre & Facility Telemetry
* `GET /api/districts` — Lists all registered healthcare districts.
* `GET /api/phcs?district_id={id}` — Returns geospatial list of PHCs, bed counts, and cold-chain capacity status.
* `GET /api/phcs/{id}/details` — Returns facility telemetry (power status, refrigeration, staffing).
* `PUT /api/phcs/{id}/capacity` — Updates cold-chain storage status and functional refrigeration units.

### Real-Time Inventory & Dispensing
* `GET /api/inventory?phc_id={id}` — Queries active stock levels, batch numbers, and days of cover.
* `POST /api/dispense` — Records patient medicine dispensation; updates stock and appends immutable audit log.
* `POST /api/emergency/requisition` — Creates rapid priority manual requisition alert for stockout crises.

### AI Engine & Optimization Endpoints
* `GET /api/forecast/{phc_id}/{medicine_id}` — Executes Holt-Winters forecast, returns 7-day projected trajectory and stockout date.
* `POST /api/optimizer/run` — Triggers the Hungarian redistribution optimizer over a district; returns proposed transfer pairs.
* `POST /api/federated/train-round` — Triggers a distributed Flower FedAvg round across district nodes.
* `POST /api/simulation/outbreak` — Injects disease outbreak surge parameters to stress-test supply resilience.

### Cold-Chain Redistribution & Driver Logistics
* `GET /api/transfers` — Lists all active, pending, and completed redistribution directives.
* `POST /api/transfers/{id}/approve` — District Medical Officer sign-off on AI-suggested transfer.
* `POST /api/transfers/{id}/assign-driver` — Assigns courier driver to approved transfer order.
* `POST /api/transfers/{id}/pickup` — Driver marks order picked up; system generates and returns 6-digit secure OTP.
* `POST /api/transfers/{id}/verify-delivery` — Verifies receiver's submitted OTP, completes order, executes atomic stock adjustment.
* `GET /api/analytics/summary` — Aggregates macro KPIs: total stockouts avoided, stock moved, active cold-chain runs.

---

## Frontend Application Architecture & Screens

The user experience is divided into 5 targeted, role-tailored responsive interfaces:

```
+------------------------------------------------------------------------------------+
|                         ROLE-BASED INTERFACE TOPOLOGY                              |
+------------------------------------------------------------------------------------+

  [1. Login / Access Portal]
     |-- Role selector (PHC Pharmacist, District Medical Officer, Logistics Driver)
     v
  +---------------------------+-----------------------------+------------------------+
  |                           |                             |                        |
  v                           v                             v                        v
  [2. PHC Dispense & Stock]   [3. District Command Console] [4. Transfers Portal]    [5. Analytics]
  - Barcode / Quick Select    - Geo-Spatial Map Layer       - Active Directives      - Stockout curves
  - Live Stock Badge Count    - District Health Matrix      - Driver Dispatch OTP    - Cost savings
  - 1-Click Dispense Record   - Outbreak Simulator Dial     - Step-by-Step Stepper   - Wastage matrix
  - Emergency Requisition    - Run Hungarian Optimizer     - Live Geodesic Vectors  - FL training log
```

### Screen Breakdown
1. **Welcome & Authentication Portal:** Minimalist authentication interface with preset quick-login toggles for live demonstration during judging.
2. **PHC Dispense & Inventory Console (51 KB):**
   * Instant search and categorization across critical medicines.
   * Color-coded stock level gauges (Red: $\le 3\text{ days}$, Amber: $3\text{--}5\text{ days}$, Green: Safe).
   * Real-time decrementing counter with instant validation preventing negative inventory state.
   * Direct trigger for Emergency Stockout Escalation.
3. **District Medical Officer (DMO) Command Center (46 KB):**
   * Multi-layered interactive OpenStreetMap showing real-time geographical clusters of all district PHCs.
   * Telemetry status badges (Refrigeration health, Power status, Total stock valuation).
   * **The "Run AI Optimizer" Action:** One-click execution of the Hungarian linear assignment engine that computes optimal redistribution vectors.
   * Outbreak Injection Drawer: Allows judges to simulate a sudden 300% dengue or snakebite surge in a selected sub-district.
4. **Redistribution & Cold-Chain Logistics Hub (74 KB):**
   * Interactive transfer cards displaying route distance, donor PHC, receiver PHC, and batch details.
   * Live visual delivery progress stepper: `Proposed -> Approved -> In-Transit -> Verified`.
   * Digital OTP Handover Interface: Driver modal displaying the 6-digit token; receiver modal with secure numeric input to complete delivery.
5. **Macro Analytics & Sovereign Intelligence Dashboard (63 KB):**
   * 7-day consumption trend vs. Holt-Winters predicted trajectory charts.
   * Sovereign Federated Learning visualization displaying current epoch, participating district nodes, and privacy loss curves.
   * Overall system metrics: Stockouts Prevented, Wastage Percentage Reduced, Average Transit Time.

---


---
## Dataset Architecture & Realistic Seeding

To ensure rigorous validation during hackathon evaluations, the project is backed by comprehensive, real-world derived datasets:

* **Geographic Registry (`PHC_Master_Template.xlsx`):** 50 authentic Primary Health Centres across 5 Telangana districts:
  1. Khammam
  2. Nalgonda
  3. Warangal
  4. Rangareddy
  5. Medak
  * All facilities include precise real-world GPS coordinates (WGS84 Latitude and Longitude).
* **Core Essential Medicines Portfolio (20 Critical Compounds):**
  * *Emergency Biologics:* Snake Antivenom Polyvalent, Rabies Vaccine (Human Diploid), Anti-Rabies Serum.
  * *Maternal & Neonatal:* Oxytocin Injection, Methylergometrine, Vitamin K1.
  * *Chronic & Endocrine:* Regular Human Insulin, Metformin 500mg, Amlodipine 5mg.
  * *Infectious Disease & Antibiotics:* Amoxicillin, Azithromycin, Paracetamol IV, ORS Sachets, Artemether-Lumefantrine.
  * *Cold-Chain Specifications:* Strict $2^\circ\text{C}$ to $8^\circ\text{C}$ limits assigned to biologics to enforce optimization constraints.
* **Historical Dispensing Logs (`dispensing_logs_mock.csv`):** 90 consecutive days of real-world modeled daily dispensing records, capturing weekly market day peaks, localized fever outbreaks, and patient demographic flags.
* **Driver Logistics Fleet (`drivers_mock.csv`):** Dedicated cold-box carrier fleet with mobile numbers and assigned transit zones.

---

## Production Deployment & Operational Topology

```
+------------------------------------------------------------------------------------+
|                         PRODUCTION DEPLOYMENT RUNTIME                              |
+------------------------------------------------------------------------------------+

  [CLIENT PLATFORMS]
         |
         +--> Mobile Device: Native Android APK (Flutter Engine)
         |
         +--> Command Room: Vercel CDN Edge (Flutter Web HTML5/CanvasKit Build)
                   |
                   | REST HTTPS Requests
                   v
  [BACKEND CLOUD ENVIRONMENT]
         Docker Containerized Linux Environment (Render / Railway / Cloud Run)
         +--------------------------------------------------------------------+
         | - Python 3.10 Runtime Environment                                  |
         | - Uvicorn Multi-Worker ASGI Server (port 8000)                     |
         | - Scientific Computing Suite (NumPy, SciPy, Statsmodels, Flower)   |
         | - Gunicorn Process Supervisor                                      |
         +---------------------------------+----------------------------------+
                                           |
                                           v
  [DATA PERSISTENCE TIER]
         PostgreSQL 15 Managed Cloud Cluster / Local Encrypted SQLite
         - Automated Schema Migration
         - ACID Enforced Concurrency Locking
```

* **Frontend Hosting:** Vercel deployment pipeline utilizing custom `vercel-build.sh` script to install Flutter stable SDK and compile optimized CanvasKit web bundles.
* **Backend Hosting:** Dockerized microservice governed by `Procfile` and `Dockerfile` ensuring predictable containerized initialization of all C-dependent math libraries (`scipy`, `statsmodels`).

---

## Key Technical Differentiators & Competitive Edge

| Capability | Standard Supply Chain Solutions | Project Resilience (Our Platform) |
| :--- | :--- | :--- |
| **Forecasting Method** | Static monthly min-max thresholds | 7-day Holt-Winters ETS capturing day-of-week clinical surge patterns. |
| **Data Privacy Policy** | Demands centralizing all patient records to cloud | Sovereign Federated Learning keeps raw data local inside district silos. |
| **Stockout Resolution** | Passive requisition ticket sent up to capital | Active lateral peer-to-peer redistribution between neighbor clinics. |
| **Redistribution Math** | Manual human guesswork | Operations Research linear assignment (Hungarian algorithm) $O(N^3)$. |
| **Cold-Chain Safety** | Assumes driver maintains temp; zero proof | Enforces 45 km radius + cryptographically verified 6-digit OTP delivery. |
| **System Availability** | Cloud-dependent; fails when internet cuts | Multi-tier degradation (Holt-Winters -> Poly-reg -> Constant baseline). |

---
