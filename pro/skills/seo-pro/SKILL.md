---
name: seo-pro
description: SEO expertise for technical optimization, content strategy, and search rankings. Use when optimizing for search engines, implementing structured data, or improving organic traffic.
allowed-tools: Read, Grep, Glob, WebFetch, WebSearch
---

# SEO Expertise

## Technical SEO

### Core Web Vitals

| Metric                          | Target  | Measurement                 |
| ------------------------------- | ------- | --------------------------- |
| LCP (Largest Contentful Paint)  | < 2.5s  | Largest element render time |
| INP (Interaction to Next Paint) | < 200ms | Input responsiveness        |
| CLS (Cumulative Layout Shift)   | < 0.1   | Visual stability            |

Optimization:

- Optimize images (WebP, lazy loading, sizing)
- Minimize JavaScript blocking
- Preload critical resources
- Use font-display: swap
- Reserve space for dynamic content

### Site Architecture

URL Structure:

```
✓ /products/category/product-name
✓ /blog/2024/01/article-title
✗ /page.php?id=123&cat=5
✗ /p/abc123xyz
```

Internal Linking:

- Flat hierarchy (3 clicks to any page)
- Descriptive anchor text
- Breadcrumb navigation
- Related content links
- XML sitemap current

### Crawlability

robots.txt:

```
User-agent: *
Allow: /
Disallow: /admin/
Disallow: /api/
Disallow: /search?

Sitemap: https://example.com/sitemap.xml
```

Meta Directives:

```html
<!-- Index, follow links (default) -->
<meta name="robots" content="index, follow" />

<!-- Don't index, but follow links -->
<meta name="robots" content="noindex, follow" />

<!-- Canonical URL -->
<link rel="canonical" href="https://example.com/page" />
```

## On-Page SEO

### Title Tags

Format: `Primary Keyword - Secondary Keyword | Brand`

Rules:

- 50-60 characters
- Primary keyword near beginning
- Unique per page
- Compelling for clicks

### Meta Descriptions

```html
<meta
  name="description"
  content="Concise, compelling description
with primary keyword. Include call-to-action. 150-160 characters."
/>
```

### Heading Structure

```html
<h1>Primary Topic (one per page)</h1>
<h2>Major Section</h2>
<h3>Subsection</h3>
<h2>Another Major Section</h2>
```

### Content Optimization

- Primary keyword in first 100 words
- Natural keyword density (1-2%)
- Related terms and synonyms (LSI)
- Answer user intent directly
- Comprehensive coverage of topic

## Structured Data

### JSON-LD Examples

Article:

```json
{
  "@context": "https://schema.org",
  "@type": "Article",
  "headline": "Article Title",
  "author": {
    "@type": "Person",
    "name": "Author Name"
  },
  "datePublished": "2024-01-15",
  "image": "https://example.com/image.jpg"
}
```

Product:

```json
{
  "@context": "https://schema.org",
  "@type": "Product",
  "name": "Product Name",
  "offers": {
    "@type": "Offer",
    "price": "29.99",
    "priceCurrency": "USD",
    "availability": "https://schema.org/InStock"
  },
  "aggregateRating": {
    "@type": "AggregateRating",
    "ratingValue": "4.5",
    "reviewCount": "89"
  }
}
```

FAQ:

```json
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "What is SEO?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "SEO (Search Engine Optimization) is..."
      }
    }
  ]
}
```

## Keyword Research

### Process

1. Seed keywords from business goals
2. Expand with tools (Ahrefs, SEMrush, Google Keyword Planner)
3. Analyze search volume and difficulty
4. Group by intent (informational, navigational, transactional)
5. Map to content strategy

### Intent Classification

| Intent        | Signal              | Content Type            |
| ------------- | ------------------- | ----------------------- |
| Informational | "how to", "what is" | Blog posts, guides      |
| Navigational  | Brand names         | Homepage, product pages |
| Commercial    | "best", "review"    | Comparison pages        |
| Transactional | "buy", "price"      | Product pages           |

## Link Building

### Quality Factors

High Value:

- Relevant, authoritative domains
- Editorial placement in content
- Descriptive anchor text
- DoFollow links

Low Value / Risky:

- Paid links (violates guidelines)
- Irrelevant sites
- Link farms / PBNs
- Exact-match anchor spam

### Strategies

- Create linkable assets (research, tools, guides)
- Digital PR and outreach
- Guest posting (quality sites only)
- Broken link building
- Resource page inclusion

## Performance Tracking

### Key Metrics

```
Organic Traffic: Sessions from search
Keyword Rankings: Position for target terms
Click-Through Rate: Clicks / Impressions
Bounce Rate: Single-page sessions
Conversion Rate: Goals / Sessions
Domain Authority: Overall site strength
```

### Tools

- Google Search Console (free, official data)
- Google Analytics (traffic analysis)
- Ahrefs / SEMrush (competitive analysis)
- Screaming Frog (technical audits)
- PageSpeed Insights (Core Web Vitals)

## Algorithm Updates

### Priorities

E-E-A-T (Experience, Expertise, Authoritativeness, Trustworthiness):

- Author credentials and bios
- Expert-written content
- Citations and sources
- Trust signals (HTTPS, privacy policy)

Helpful Content:

- User-first content
- Satisfies search intent
- Original research / insights
- Comprehensive coverage

## Quality Checklist

- [ ] Core Web Vitals passing
- [ ] Mobile-friendly verified
- [ ] Structured data implemented
- [ ] XML sitemap current
- [ ] Canonical URLs set
- [ ] Title tags optimized
- [ ] Internal linking logical
- [ ] Content satisfies intent
