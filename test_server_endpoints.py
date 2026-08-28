import time
import requests
import json
from server.main import app
from fastapi.testclient import TestClient

client = TestClient(app)

print("=== 1. Testing GET /api/metadata ===")
t0 = time.time()
res = client.get("/api/metadata")
dt = (time.time() - t0) * 1000
print(f"Status: {res.status_code} (took {dt:.1f}ms)")
assert res.status_code == 200
meta = res.json()
print(f"  Total DB reports: {meta.get('total_reports'):,}")
print(f"  Categories: {meta.get('categories')}")
print(f"  Canonical brands: {len(meta.get('canonical_brands', []))} brands")

print("\n=== 2. Testing POST /api/stats/overview ===")
t0 = time.time()
res = client.post("/api/stats/overview", json={"categories": ["CGM"], "brands": ["Dexcom G7", "Libre 2"]})
dt = (time.time() - t0) * 1000
print(f"Status: {res.status_code} (took {dt:.1f}ms)")
assert res.status_code == 200
overview = res.json()
print(f"  Filtered reports: {overview.get('total_reports'):,}")
print(f"  Deaths: {overview.get('death_count'):,}, Injuries: {overview.get('injury_count'):,}")

print("\n=== 3. Testing POST /api/reports (Pagination & Search) ===")
t0 = time.time()
res = client.post("/api/reports?page=1&page_size=10", json={"keyword": "sensor"})
dt = (time.time() - t0) * 1000
print(f"Status: {res.status_code} (took {dt:.1f}ms)")
assert res.status_code == 200
reports_data = res.json()
print(f"  Total matched keyword 'sensor': {reports_data.get('total'):,}")
print(f"  Returned items: {len(reports_data.get('items', []))}")
if reports_data.get("items"):
    first_no = reports_data["items"][0]["report_number"]
    print(f"  First report number: {first_no}")
    
    # Test Detail
    res_detail = client.get(f"/api/reports/{first_no}")
    assert res_detail.status_code == 200
    print(f"  Successfully fetched detail for {first_no}")

print("\n=== 4. Testing POST /api/stats/monthly ===")
t0 = time.time()
res = client.post("/api/stats/monthly", json={})
dt = (time.time() - t0) * 1000
print(f"Status: {res.status_code} (took {dt:.1f}ms)")
assert res.status_code == 200
print(f"  Monthly points returned: {len(res.json()):,}")

print("\n=== 5. Testing POST /api/stats/problem-codes ===")
t0 = time.time()
res = client.post("/api/stats/problem-codes?limit=10", json={})
dt = (time.time() - t0) * 1000
print(f"Status: {res.status_code} (took {dt:.1f}ms)")
assert res.status_code == 200
pc = res.json()
print(f"  Top patient problems: {len(pc.get('patient_problems', []))}")
print(f"  Top product problems: {len(pc.get('product_problems', []))}")

print("\n=== 6. Testing POST /api/insights ===")
t0 = time.time()
res = client.post("/api/insights", json={})
dt = (time.time() - t0) * 1000
print(f"Status: {res.status_code} (took {dt:.1f}ms)")
assert res.status_code == 200

print("\n[SUCCESS] ALL BACKEND API TESTS PASSED SUCCESSFULLY!")
