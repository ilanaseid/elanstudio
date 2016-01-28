class GoogleFeed

  TAXONOMY = {
    fashion: {
      tops: 'Apparel & Accessories > Clothing > Shirts & Tops',
      bottoms: 'Apparel & Accessories > Clothing',
      dresses: 'Apparel & Accessories > Clothing > Dresses',
      jackets: 'Apparel & Accessories > Clothing > Outerwear > Coats & Jackets',
      outerwear: 'Apparel & Accessories > Clothing > Outerwear',
      shoes: 'Apparel & Accessories > Shoes',
      accessories: 'Apparel & Accessories > Clothing Accessories',
      bags: 'Apparel & Accessories > Handbags, Wallets & Cases > Handbags',
      jewelry: 'Apparel & Accessories > Jewelry',
      swim: 'Apparel & Accessories > Clothing > Swimwear',
      lingerie: 'Apparel & Accessories > Clothing > Underwear & Socks > Lingerie'
    },
    home: {
      furniture: 'Furniture',
      tableware: 'Home & Garden > Kitchen & Dining > Tableware',
      lighting: 'Home & Garden > Lighting',
      textiles: 'Home & Garden > Decor',
      rugs: 'Home & Garden > Decor > Rugs',
      accessories: 'Home & Garden > Decor',
      books: 'Media > Books',
      cleaning: 'Home & Garden > Household Supplies > Household Cleaning Supplies',
      pet: 'Animals & Pet Supplies > Pet Supplies > Dog Supplies',
      garden: 'Home & Garden > Lawn & Garden > Gardening > Gardening Accessories'
    },
    beauty: {
      face: 'Health & Beauty > Personal Care > Cosmetics > Skin Care',
      bath_body: 'Health & Beauty > Personal Care > Cosmetics > Bath & Body',
      hair: 'Health & Beauty > Personal Care > Hair Care',
      fragrance: 'Health & Beauty > Personal Care > Cosmetics > Perfume & Cologne'
    },
    art: {
      art: 'Arts & Entertainment > Hobbies & Creative Arts > Artwork'
    }
  }

  HEADERS = [
    'id',
    'title',
    'description',
    'google product category',
    'product type',
    'link',
    'image link',
    'condition',
    'availability',
    'price',
    'brand',
    'mpn',
    'identifier exists',
    'gender',
    'age group',
    'color',
    'size',
    'item group id',
    'material',
    'adwords grouping',
    'adwords labels',
    'adwords redirect'
  ]

end
