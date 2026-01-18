"""
Content Hub Service - Article Management
Handles reading, filtering, and serving educational articles from JSON files
"""
import json
import os
from pathlib import Path
from typing import List, Dict, Optional
from datetime import datetime


class ContentService:
    """Service for managing educational content articles"""
    
    def __init__(self):
        self.articles_dir = Path(__file__).parent.parent / "content" / "articles"
        self._articles_cache = None
        self._last_load_time = None
        
    def _load_articles(self, force_reload: bool = False) -> List[Dict]:
        """Load all articles from JSON files with caching"""
        # Cache for 5 minutes to avoid constant file reads
        if (not force_reload and 
            self._articles_cache is not None and 
            self._last_load_time is not None and
            (datetime.now() - self._last_load_time).seconds < 300):
            return self._articles_cache
            
        articles = []
        
        # Read all JSON files in articles directory
        for file_path in self.articles_dir.glob("*.json"):
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    article = json.load(f)
                    articles.append(article)
            except Exception as e:
                print(f"Error loading article {file_path}: {e}")
                continue
                
        self._articles_cache = articles
        self._last_load_time = datetime.now()
        return articles
    
    def get_all_articles(
        self, 
        category: Optional[str] = None,
        tags: Optional[List[str]] = None,
        featured_only: bool = False
    ) -> List[Dict]:
        """
        Get list of all articles with optional filtering
        Returns lightweight version without full content
        """
        articles = self._load_articles()
        
        # Apply filters
        if category:
            articles = [a for a in articles if a.get('category') == category]
            
        if tags:
            articles = [
                a for a in articles 
                if any(tag in a.get('tags', []) for tag in tags)
            ]
            
        if featured_only:
            articles = [a for a in articles if a.get('featured', False)]
        
        # Return lightweight version (no content array)
        result = []
        for article in articles:
            lightweight = {k: v for k, v in article.items() if k != 'content'}
            # Add content summary
            lightweight['contentPreview'] = self._get_preview(article)
            result.append(lightweight)
            
        # Sort by featured first, then by publish date
        result.sort(
            key=lambda x: (not x.get('featured', False), x.get('publishedDate', '')),
            reverse=True
        )
        
        return result
    
    def get_article_by_slug(self, slug: str) -> Optional[Dict]:
        """Get complete article by slug including full content"""
        articles = self._load_articles()
        
        for article in articles:
            if article.get('slug') == slug:
                return article
                
        return None
    
    def get_related_articles(self, slug: str, limit: int = 3) -> List[Dict]:
        """Get related articles for a given article"""
        article = self.get_article_by_slug(slug)
        if not article:
            return []
            
        related_slugs = article.get('relatedArticles', [])
        articles = self._load_articles()
        
        related = []
        for a in articles:
            if a.get('slug') in related_slugs:
                lightweight = {k: v for k, v in a.items() if k != 'content'}
                lightweight['contentPreview'] = self._get_preview(a)
                related.append(lightweight)
                
        return related[:limit]
    
    def search_articles(self, query: str) -> List[Dict]:
        """Search articles by title, subtitle, tags, or content"""
        query_lower = query.lower()
        articles = self._load_articles()
        
        matching = []
        for article in articles:
            # Search in title, subtitle, tags
            if (query_lower in article.get('title', '').lower() or
                query_lower in article.get('subtitle', '').lower() or
                any(query_lower in tag.lower() for tag in article.get('tags', []))):
                
                lightweight = {k: v for k, v in article.items() if k != 'content'}
                lightweight['contentPreview'] = self._get_preview(article)
                matching.append(lightweight)
                
        return matching
    
    def get_categories(self) -> List[Dict[str, any]]:
        """Get list of all categories with article counts"""
        articles = self._load_articles()
        categories = {}
        
        for article in articles:
            cat = article.get('category', 'uncategorized')
            if cat not in categories:
                categories[cat] = {'name': cat, 'count': 0}
            categories[cat]['count'] += 1
            
        return list(categories.values())
    
    def _get_preview(self, article: Dict) -> str:
        """Extract preview text from article content"""
        content = article.get('content', [])
        
        # Get first introduction or section
        for item in content:
            if item.get('type') in ['introduction', 'section']:
                body = item.get('body', '')
                # Return first 200 characters
                if len(body) > 200:
                    return body[:197] + '...'
                return body
                
        return ''
    
    def get_recommendations_for_life_seal(self, life_seal: int, limit: int = 3) -> List[Dict]:
        """Get recommended articles based on user's Life Seal number"""
        articles = self._load_articles()
        
        recommended = []
        
        # Priority 1: The specific Life Seal deep-dive article
        life_seal_slug = f'life-seal-{life_seal}-'  # Will match life-seal-1-pioneer, etc.
        specific_article = None
        
        for article in articles:
            slug = article.get('slug', '')
            if slug.startswith(life_seal_slug):
                lightweight = {k: v for k, v in article.items() if k != 'content'}
                lightweight['contentPreview'] = self._get_preview(article)
                specific_article = lightweight
                break
        
        # Add the specific Life Seal article first
        if specific_article:
            recommended.append(specific_article)
        
        # Priority 2: Other life-seals category articles
        for article in articles:
            if len(recommended) >= limit:
                break
            slug = article.get('slug', '')
            category = article.get('category', '')
            
            # Skip the one we already added and add other Life Seal articles
            if category == 'life-seals' and not slug.startswith(life_seal_slug):
                lightweight = {k: v for k, v in article.items() if k != 'content'}
                lightweight['contentPreview'] = self._get_preview(article)
                recommended.append(lightweight)
        
        # Priority 3: Fill with related topics if needed
        if len(recommended) < limit:
            for article in articles:
                if len(recommended) >= limit:
                    break
                tags = article.get('tags', [])
                category = article.get('category', '')
                slug = article.get('slug', '')
                
                # Skip already added
                if any(slug == r['slug'] for r in recommended):
                    continue
                
                # Add related numerology topics
                if any(tag in tags for tag in ['life seal', 'life path', 'soul purpose', 'destiny']):
                    lightweight = {k: v for k, v in article.items() if k != 'content'}
                    lightweight['contentPreview'] = self._get_preview(article)
                    recommended.append(lightweight)
                
        return recommended[:limit]


# Global service instance
content_service = ContentService()
