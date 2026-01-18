"""
Content Hub API Routes
Educational articles and content management endpoints
"""
from fastapi import APIRouter, HTTPException, Query
from typing import List, Optional
from pydantic import BaseModel

from app.services.content_service import content_service


router = APIRouter(prefix="/content", tags=["content"])


class ArticleListItem(BaseModel):
    """Lightweight article for list views"""
    id: str
    slug: str
    title: str
    subtitle: str
    category: str
    author: str
    readTime: int
    publishedDate: str
    tags: List[str]
    featured: bool
    coverImage: Optional[str] = None
    contentPreview: str


class ArticleDetail(BaseModel):
    """Full article with content"""
    id: str
    slug: str
    title: str
    subtitle: str
    category: str
    author: str
    readTime: int
    publishedDate: str
    tags: List[str]
    featured: bool
    relatedArticles: List[str]
    coverImage: Optional[str] = None
    content: List[dict]


class CategoryInfo(BaseModel):
    """Category with article count"""
    name: str
    count: int


@router.get("/articles", response_model=List[ArticleListItem])
async def get_articles(
    category: Optional[str] = Query(None, description="Filter by category"),
    tags: Optional[str] = Query(None, description="Comma-separated tags to filter by"),
    featured: bool = Query(False, description="Only return featured articles"),
    search: Optional[str] = Query(None, description="Search query")
):
    """
    Get list of articles with optional filtering
    
    - **category**: Filter by category (basics, life-seals, cycles, compatibility, advanced)
    - **tags**: Comma-separated list of tags to filter by
    - **featured**: If true, only return featured articles
    - **search**: Search in title, subtitle, tags
    """
    try:
        if search:
            articles = content_service.search_articles(search)
        else:
            tag_list = tags.split(',') if tags else None
            articles = content_service.get_all_articles(
                category=category,
                tags=tag_list,
                featured_only=featured
            )
        
        return articles
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching articles: {str(e)}")


@router.get("/articles/{slug}", response_model=ArticleDetail)
async def get_article(slug: str):
    """
    Get complete article by slug including full content
    
    - **slug**: Article slug identifier
    """
    try:
        article = content_service.get_article_by_slug(slug)
        
        if not article:
            raise HTTPException(status_code=404, detail=f"Article '{slug}' not found")
            
        return article
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching article: {str(e)}")


@router.get("/articles/{slug}/related", response_model=List[ArticleListItem])
async def get_related_articles(
    slug: str,
    limit: int = Query(3, ge=1, le=10, description="Number of related articles to return")
):
    """
    Get related articles for a specific article
    
    - **slug**: Article slug to find related articles for
    - **limit**: Maximum number of related articles (1-10, default 3)
    """
    try:
        related = content_service.get_related_articles(slug, limit)
        return related
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching related articles: {str(e)}")


@router.get("/categories", response_model=List[CategoryInfo])
async def get_categories():
    """
    Get list of all article categories with counts
    """
    try:
        categories = content_service.get_categories()
        return categories
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching categories: {str(e)}")


@router.get("/recommendations/{life_seal}", response_model=List[ArticleListItem])
async def get_recommendations(
    life_seal: int,
    limit: int = Query(3, ge=1, le=10, description="Number of recommendations")
):
    """
    Get article recommendations based on Life Seal number
    
    - **life_seal**: User's Life Seal number (1-9)
    - **limit**: Maximum number of recommendations (1-10, default 3)
    """
    if life_seal < 1 or life_seal > 9:
        raise HTTPException(status_code=400, detail="Life Seal must be between 1 and 9")
    
    try:
        recommendations = content_service.get_recommendations_for_life_seal(life_seal, limit)
        return recommendations
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching recommendations: {str(e)}")


@router.post("/articles/{slug}/view")
async def track_article_view(slug: str):
    """
    Track article view for analytics
    
    - **slug**: Article slug that was viewed
    
    Currently just validates article exists.
    Future: Could log to database for analytics.
    """
    try:
        article = content_service.get_article_by_slug(slug)
        
        if not article:
            raise HTTPException(status_code=404, detail=f"Article '{slug}' not found")
        
        # Future: Log view to analytics database
        # For now, just return success
        return {"status": "success", "slug": slug, "message": "View tracked"}
    
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error tracking view: {str(e)}")
