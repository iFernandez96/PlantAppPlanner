export const meta = {
  name: 'catalog-phase2-cited-research',
  description: 'Fan out one cited care-research agent per pilot plant; each writes a schema-conforming PlantProfile JSON with authoritative source citations into scratch/catalog/profiles/',
  phases: [{ title: 'Research', detail: 'one agent per plant: authoritative cited care data -> profile JSON' }],
}

// 75 pilot plants (from scratch/catalog/pilot-list.md). 5 already exist in the live seed
// (version 1): solanum-lycopersicum, fragaria-x-ananassa, passiflora-edulis,
// physalis-philadelphica, ocimum-basilicum -> ENRICH (version 2), keep id+scientificName.
const SEEDED = {
  'solanum-lycopersicum': '{"watering":{"baseIntervalDays":2,"dryingTolerance":"low"},"feeding":{"baseIntervalDays":7,"fruitingIntervalDays":5},"container":{"recommendedMinLiters":19},"light":{"targetSunHours":8},"temp":{"frostSensitive":true},"requiresSupport":true,"selfFruitful":true}',
  'fragaria-x-ananassa': '{"watering":{"baseIntervalDays":2,"dryingTolerance":"low"},"feeding":{"baseIntervalDays":14,"postHarvestIntervalDays":21},"container":{"recommendedMinLiters":4},"light":{"targetSunHours":6},"temp":{"frostSensitive":false},"selfFruitful":true}',
  'passiflora-edulis': '{"watering":{"baseIntervalDays":3,"dryingTolerance":"medium"},"feeding":{"baseIntervalDays":14},"container":{"recommendedMinLiters":95},"light":{"targetSunHours":6},"temp":{"frostSensitive":true},"requiresSupport":true,"selfFruitful":true}',
  'physalis-philadelphica': '{"watering":{"baseIntervalDays":3,"dryingTolerance":"medium"},"feeding":{"baseIntervalDays":10},"container":{"recommendedMinLiters":19},"light":{"targetSunHours":7},"temp":{"frostSensitive":true},"selfFruitful":false,"pollinationPartnersRequired":2}',
  'ocimum-basilicum': '{"watering":{"baseIntervalDays":1.5,"dryingTolerance":"low"},"feeding":{"baseIntervalDays":14},"container":{"recommendedMinLiters":3},"light":{"targetSunHours":6},"temp":{"frostSensitive":true},"selfFruitful":true}',
}

const PLANTS = [
  ['Tomato','Solanum lycopersicum','vegetable','solanum-lycopersicum'],
  ['Lettuce','Lactuca sativa','vegetable','lactuca-sativa'],
  ['Radish','Raphanus sativus','vegetable','raphanus-sativus'],
  ['Green bean','Phaseolus vulgaris','vegetable','phaseolus-vulgaris'],
  ['Zucchini','Cucurbita pepo','vegetable','cucurbita-pepo'],
  ['Cucumber','Cucumis sativus','vegetable','cucumis-sativus'],
  ['Spinach','Spinacia oleracea','vegetable','spinacia-oleracea'],
  ['Kale','Brassica oleracea (Acephala)','vegetable','brassica-oleracea-acephala'],
  ['Pea','Pisum sativum','vegetable','pisum-sativum'],
  ['Carrot','Daucus carota sativus','root','daucus-carota'],
  ['Bell pepper','Capsicum annuum','vegetable','capsicum-annuum'],
  ['Swiss chard','Beta vulgaris cicla','vegetable','beta-vulgaris-cicla'],
  ['Beet','Beta vulgaris','root','beta-vulgaris'],
  ['Broccoli','Brassica oleracea (Italica)','vegetable','brassica-oleracea-italica'],
  ['Green onion','Allium fistulosum','vegetable','allium-fistulosum'],
  ['Garlic','Allium sativum','vegetable','allium-sativum'],
  ['Basil','Ocimum basilicum','herb','ocimum-basilicum'],
  ['Mint','Mentha spicata','herb','mentha-spicata'],
  ['Chives','Allium schoenoprasum','herb','allium-schoenoprasum'],
  ['Parsley','Petroselinum crispum','herb','petroselinum-crispum'],
  ['Cilantro','Coriandrum sativum','herb','coriandrum-sativum'],
  ['Thyme','Thymus vulgaris','herb','thymus-vulgaris'],
  ['Rosemary','Salvia rosmarinus','herb','salvia-rosmarinus'],
  ['Oregano','Origanum vulgare','herb','origanum-vulgare'],
  ['Dill','Anethum graveolens','herb','anethum-graveolens'],
  ['Sage','Salvia officinalis','herb','salvia-officinalis'],
  ['Lavender','Lavandula angustifolia','herb','lavandula-angustifolia'],
  ['Lemon balm','Melissa officinalis','herb','melissa-officinalis'],
  ['Tarragon','Artemisia dracunculus','herb','artemisia-dracunculus'],
  ['Fennel','Foeniculum vulgare','herb','foeniculum-vulgare'],
  ['Strawberry','Fragaria x ananassa','berry','fragaria-x-ananassa'],
  ['Blueberry','Vaccinium corymbosum','berry','vaccinium-corymbosum'],
  ['Raspberry','Rubus idaeus','berry','rubus-idaeus'],
  ['Blackberry','Rubus fruticosus','berry','rubus-fruticosus'],
  ['Gooseberry','Ribes uva-crispa','berry','ribes-uva-crispa'],
  ['Red currant','Ribes rubrum','berry','ribes-rubrum'],
  ['Fig','Ficus carica','fruit','ficus-carica'],
  ['Lemon','Citrus limon','fruit','citrus-limon'],
  ['Apple','Malus domestica','fruit','malus-domestica'],
  ['Peach','Prunus persica','fruit','prunus-persica'],
  ['Cherry','Prunus avium','fruit','prunus-avium'],
  ['Plum','Prunus domestica','fruit','prunus-domestica'],
  ['Pear','Pyrus communis','fruit','pyrus-communis'],
  ['Grape','Vitis vinifera','vine','vitis-vinifera'],
  ['Kiwi','Actinidia deliciosa','vine','actinidia-deliciosa'],
  ['Passion fruit','Passiflora edulis','fruit','passiflora-edulis'],
  ['Tomatillo','Physalis philadelphica','fruit','physalis-philadelphica'],
  ['Marigold','Tagetes patula','ornamental','tagetes-patula'],
  ['Sunflower','Helianthus annuus','ornamental','helianthus-annuus'],
  ['Zinnia','Zinnia elegans','ornamental','zinnia-elegans'],
  ['Petunia','Petunia x hybrida','ornamental','petunia-x-hybrida'],
  ['Geranium','Pelargonium x hortorum','ornamental','pelargonium-x-hortorum'],
  ['Pansy','Viola x wittrockiana','ornamental','viola-x-wittrockiana'],
  ['Rose','Rosa x hybrida','ornamental','rosa-x-hybrida'],
  ['Dahlia','Dahlia pinnata','ornamental','dahlia-pinnata'],
  ['Impatiens','Impatiens walleriana','ornamental','impatiens-walleriana'],
  ['Begonia','Begonia semperflorens','ornamental','begonia-semperflorens'],
  ['Black-eyed Susan','Rudbeckia hirta','ornamental','rudbeckia-hirta'],
  ['Cosmos','Cosmos bipinnatus','ornamental','cosmos-bipinnatus'],
  ['Snapdragon','Antirrhinum majus','ornamental','antirrhinum-majus'],
  ['Salvia (scarlet)','Salvia splendens','ornamental','salvia-splendens'],
  ['Sweet alyssum','Lobularia maritima','ornamental','lobularia-maritima'],
  ['Pothos','Epipremnum aureum','houseplant','epipremnum-aureum'],
  ['Snake plant','Dracaena trifasciata','houseplant','dracaena-trifasciata'],
  ['Monstera','Monstera deliciosa','houseplant','monstera-deliciosa'],
  ['Spider plant','Chlorophytum comosum','houseplant','chlorophytum-comosum'],
  ['Peace lily','Spathiphyllum wallisii','houseplant','spathiphyllum-wallisii'],
  ['ZZ plant','Zamioculcas zamiifolia','houseplant','zamioculcas-zamiifolia'],
  ['Rubber plant','Ficus elastica','houseplant','ficus-elastica'],
  ['Heartleaf philodendron','Philodendron hederaceum','houseplant','philodendron-hederaceum'],
  ['Chinese evergreen','Aglaonema commutatum','houseplant','aglaonema-commutatum'],
  ['Aloe vera','Aloe vera','succulent','aloe-vera'],
  ['Jade plant','Crassula ovata','succulent','crassula-ovata'],
  ['Echeveria','Echeveria elegans','succulent','echeveria-elegans'],
  ['Haworthia','Haworthia attenuata','succulent','haworthia-attenuata'],
]

// Map pilot "houseplant" -> schema "other" (schema enum lacks houseplant).
const CATEGORY_MAP = { houseplant: 'other' }

// StructuredOutput summary (the heavy profile JSON is written to disk by the agent).
const SUMMARY = {
  type: 'object',
  additionalProperties: false,
  required: ['profileId', 'written', 'citationCount', 'sourcesUsed', 'lowConfidenceFields', 'notes'],
  properties: {
    profileId: { type: 'string' },
    written: { type: 'boolean', description: 'true if the profile JSON file was written to disk' },
    citationCount: { type: 'integer', minimum: 0 },
    sourcesUsed: { type: 'array', items: { type: 'string' }, description: 'short names of the authoritative sources cited, e.g. ["RHS","UMN Extension"]' },
    lowConfidenceFields: { type: 'array', items: { type: 'string' }, description: 'fields where authoritative data was thin/estimated' },
    notes: { type: 'string', description: 'one or two sentences: data quality, anything notable, or why a field was estimated' },
  },
}

const OUT_DIR = '/home/israel/Documents/Development/PlantAppPlanner/scratch/catalog/profiles'

const SCHEMA_TEXT = `PlantProfile schema (draft 2020-12, additionalProperties:false everywhere shown):
{
  id: string ^[a-z0-9-]+$            // MUST equal the profileId given to you
  scientificName: string
  commonNames: string[] (>=1)
  category: "fruit"|"vegetable"|"herb"|"ornamental"|"vine"|"root"|"berry"|"succulent"|"other"
  growthHabit: "bush"|"vine"|"trailing"|"upright"|"climbing"|"rosette"|"tree"
  requiresSupport?: boolean (default false)
  selfFruitful?: boolean|null        // null if N/A (e.g. foliage houseplants, leafy greens)
  pollinationPartnersRequired?: integer >=0 (default 0)
  wateringProfile: { baseIntervalDays: number>=0.25 (REQUIRED), dryingTolerance: "low"|"medium"|"high" (REQUIRED),
                     overwaterRisk?: "low"|"medium"|"high", hotWeatherMultiplier?: number>=0, rainSkipThresholdMm?: number>=0 }
  feedingProfile: { baseIntervalDays: number>=1 (REQUIRED), fruitingIntervalDays?: number>=1,
                    postHarvestIntervalDays?: number>=1, containerLeachAdjustment?: number, preferredNpk?: string }
  containerProfile: { recommendedMinLiters: number>=0 (REQUIRED), idealMinLiters?: number>=0, idealMaxLiters?: number>=0, soilMixTags?: string[] }
  lightProfile: { targetSunHours: number>=0 (REQUIRED), minSunHours?: number>=0, maxSunHours?: number>=0 }
  temperatureProfile: { coldHardyMinC?: number, heatStressC?: number, frostSensitive?: boolean (default false) }
  seasonality?: { plantingWindowsByZone?: {<zone>: [{startMonth:1-12,endMonth:1-12}]}, productiveMonths?: int[1-12], dormancyMonths?: int[1-12] }
  commonIssues?: string[]
  verticalSuitability?: number 0..1   // 1 = ideal for vertical/trellis/hanging growing
  source: [ { citation: string (REQUIRED), url?: uri, field?: string } ]   // citations; use field to tag which group a source backs
  version: integer >=1 (REQUIRED)
  lastReviewedAt?: "YYYY-MM-DD"
}
WORKED EXAMPLE (real seeded tomato, minimal — you should produce a MORE COMPLETE profile than this):
{"id":"solanum-lycopersicum","scientificName":"Solanum lycopersicum","commonNames":["Tomato"],"category":"fruit","growthHabit":"vine","requiresSupport":true,"selfFruitful":true,"pollinationPartnersRequired":0,"wateringProfile":{"baseIntervalDays":2,"dryingTolerance":"low"},"feedingProfile":{"baseIntervalDays":7,"fruitingIntervalDays":5},"containerProfile":{"recommendedMinLiters":19},"lightProfile":{"targetSunHours":8},"temperatureProfile":{"frostSensitive":true},"version":1}`

phase('Research')

const results = await parallel(PLANTS.map(([common, sci, pilotCat, profileId]) => async () => {
  const category = CATEGORY_MAP[pilotCat] || pilotCat
  const seeded = SEEDED[profileId]
  const seededNote = seeded
    ? `\nNOTE: this id ALREADY EXISTS in the live seed (version 1) with these minimal values: ${seeded}. ENRICH it — keep id and scientificName, keep those proven core values unless authoritative sources strongly contradict, and FILL the missing optional fields (overwaterRisk, idealMin/MaxLiters, light min/max, temperature, seasonality, commonIssues, verticalSuitability, feeding detail). Set version: 2 to mark the enrichment.`
    : '\nThis is a NEW profile. Set version: 1.'
  return agent(
    `You are a horticulture data researcher for a plant-care app. Produce ONE schema-conforming PlantProfile for:
- Common name: ${common}
- Scientific name: ${sci}
- profileId (use as "id"): ${profileId}
- category (use exactly this enum value): ${category}
${seededNote}

RULES:
1. Use ONLY authoritative sources: US university extension services (.edu — e.g. UMN, Clemson, UC, Cornell, Missouri Botanical Garden / plantfinder), the RHS (rhs.org.uk), and the Old Farmer's Almanac. Use WebSearch + WebFetch to find and READ real pages. DO NOT invent or guess horticulture — this is a care app where wrong data harms plants.
2. Every non-obvious numeric/categorical value (watering interval, container liters, sun hours, temperatures, intervals) MUST be backed by a "source" entry citing a real page you actually read, with its real url and a "field" tag (e.g. "wateringProfile","containerProfile","lightProfile"). Aim for >=2 distinct authoritative sources.
3. Convert units to the schema's (liters for containers, hours/day for light, Celsius for temperatures, days for intervals). Container minimum = a realistic pot size for growing this in a container; for in-ground-only large trees give a sensible large-container minimum and note it in commonIssues.
4. If a value is genuinely uncertain/estimated, still provide a reasonable conservative number AND list that field in the "lowConfidenceFields" of your returned summary AND add a source entry with field="confidence" describing the gap.
5. selfFruitful: null for foliage/leafy/root plants where fruiting is N/A. requiresSupport/pollinationPartnersRequired only where horticulturally real.
6. Set lastReviewedAt to "2026-06-02".

OUTPUT:
- WRITE the complete profile JSON (pretty-printed, 2-space indent) to the file: ${OUT_DIR}/${profileId}.json  (use the Write tool; overwrite if present).
- The JSON MUST validate against this schema (additionalProperties:false — include NO keys not in the schema; do not add a "confidence" top-level key, encode confidence via a source entry with field="confidence"):
${SCHEMA_TEXT}

Then return the structured summary (profileId, whether you wrote the file, citation count, the short source names you used, low-confidence fields, and a one/two-sentence note).`,
    { label: profileId, phase: 'Research', schema: SUMMARY, agentType: 'general-purpose' }
  )
}))

const ok = results.filter(Boolean)
return {
  requested: PLANTS.length,
  returned: ok.length,
  written: ok.filter(r => r.written).length,
  lowConfidence: ok.filter(r => (r.lowConfidenceFields || []).length).map(r => ({ id: r.profileId, fields: r.lowConfidenceFields })),
  summaries: ok,
}
