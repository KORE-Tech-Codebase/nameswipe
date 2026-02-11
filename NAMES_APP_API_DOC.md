# Names App API

Base URL: `https://comm-app-data-api.vercel.app/api/v1/names-app`

All requests require `x-api-key` header.

---

## List Categories

```
GET /api/v1/names-app
```

Returns all available categories with counts (male/female/unisex per category).

---

## List / Search / Filter Names

```
GET /api/v1/names-app/{category}
```

**Categories:** `african`, `celtic`, `christian`, `east_asian`, `english`, `european`, `french`, `german`, `greek`, `hindu`, `italian`, `jewish`, `latin`, `muslim`, `scandinavian`, `slavic`, `spanish`, `turkish`, `other`

**Query params:**

| Param | Example | Description |
|-------|---------|-------------|
| `search` | `?search=ahmad` | Search in name + meaning |
| `filter[gender]` | `?filter[gender]=male` | Filter by gender (`male`, `female`, `unisex`) |
| `filter[origin]` | `?filter[origin]=Arabic` | Filter by origin |
| `page` | `?page=2` | Page number (default: 1) |
| `pageSize` | `?pageSize=50` | Items per page (default: 20, max: 100) |
| `sort` | `?sort=name` | Sort by field (default: `name`) |
| `sortDirection` | `?sortDirection=desc` | `asc` or `desc` |

**Examples:**

```bash
# All Muslim male names, page 1
curl -H "x-api-key: rehan-komail-comm-app-api-service" \
  "https://comm-app-data-api.vercel.app/api/v1/names-app/muslim?filter[gender]=male"

# Search for "ahmad" in Muslim names
curl -H "x-api-key: rehan-komail-comm-app-api-service" \
  "https://comm-app-data-api.vercel.app/api/v1/names-app/muslim?search=ahmad"

# English female names of Latin origin, page 2
curl -H "x-api-key: rehan-komail-comm-app-api-service" \
  "https://comm-app-data-api.vercel.app/api/v1/names-app/english?filter[gender]=female&filter[origin]=Latin&page=2"
```

---

## Random Names

```
GET /api/v1/names-app/{category}/random?count=5
```

Returns 1 random name by default, or up to 100 with `count` param.

```bash
curl -H "x-api-key: rehan-komail-comm-app-api-service" \
  "https://comm-app-data-api.vercel.app/api/v1/names-app/hindu/random?count=3"
```

---

## Category Stats

```
GET /api/v1/names-app/{category}/stats
```

Returns total records and unique value counts for each filterable field.

```bash
curl -H "x-api-key: rehan-komail-comm-app-api-service" "https://comm-app-data-api.vercel.app/api/v1/names-app/muslim/stats"
```

---

## Response Format

**Success:**
```json
{
  "success": true,
  "data": [...],
  "meta": { "page": 1, "pageSize": 20, "total": 2776, "totalPages": 139, "hasNext": true, "hasPrev": false }
}
```

**Error:**
```json
{
  "success": false,
  "error": { "code": "NOT_FOUND", "message": "Category \"xyz\" not found" }
}
```
