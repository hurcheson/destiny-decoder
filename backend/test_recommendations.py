from app.services.content_service import content_service

# Test recommendations for each Life Seal
for life_seal in range(1, 10):
    print(f'\n=== Life Seal {life_seal} Recommendations ===')
    recs = content_service.get_recommendations_for_life_seal(life_seal, 3)
    for i, r in enumerate(recs, 1):
        print(f'  {i}. {r["title"]}')
        print(f'     Slug: {r["slug"]}')
        print(f'     Category: {r["category"]}')
