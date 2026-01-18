# Article Schema Documentation

## Article JSON Structure

```json
{
  "id": "unique-identifier",
  "slug": "url-friendly-slug",
  "title": "Article Title",
  "subtitle": "Brief compelling subtitle",
  "category": "basics|life-seals|cycles|compatibility|advanced",
  "author": "Destiny Decoder Team",
  "readTime": 8,
  "publishedDate": "2026-01-18",
  "tags": ["numerology", "life-seal", "spirituality"],
  "featured": false,
  "relatedArticles": ["article-slug-1", "article-slug-2"],
  "coverImage": "/images/articles/cover.jpg",
  "content": [
    {
      "type": "introduction",
      "body": "Opening paragraph..."
    },
    {
      "type": "section",
      "heading": "Section Title",
      "body": "Section content with **markdown** support..."
    },
    {
      "type": "callout",
      "style": "info|warning|success",
      "body": "Important note..."
    },
    {
      "type": "quote",
      "text": "Inspirational quote",
      "author": "Author Name"
    },
    {
      "type": "list",
      "heading": "Key Points",
      "items": ["Point 1", "Point 2", "Point 3"]
    }
  ]
}
```

## Categories

- **basics**: Introduction to numerology concepts
- **life-seals**: Deep dives into each Life Seal (1-9)
- **cycles**: Life Cycles, Turning Points, Pinnacles
- **compatibility**: Relationship numerology
- **advanced**: Master numbers, advanced calculations

## Content Types

- **introduction**: Opening paragraph (no heading)
- **section**: Regular content section with heading
- **callout**: Highlighted box (info/warning/success)
- **quote**: Inspirational quote block
- **list**: Bulleted or numbered list
- **image**: Image with caption
- **table**: Data table

## Tags

Common tags: numerology, life-seal, life-cycles, compatibility, personal-year, 
master-numbers, spirituality, career, relationships, finance, daily-practice
