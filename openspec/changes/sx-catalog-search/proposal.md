## Why

The legacy Java Pet Store Lite lets shoppers find items by keyword from a search box on every page. The rebuild has to reproduce that behaviour, including several rules the User Guide does not state or states wrongly: case handling, wildcard characters, unordered results and attribute exclusion. This change records the search behaviour recovered from the legacy code, configuration, User Guide and captured search samples (SX-0001) as verifiable requirements.

## What Changes

- Add the `catalog-search` capability: keyword tokenisation and matching, any-word semantics, locale restriction, empty and no-match handling, paging at two results per page, the result data, and request text decoding.
- Add two screen requirements: the banner search box and the Search results page.
- Record three disputed or defect-shaped behaviours as draft requirements for a business decision: a keyword with a capital letter matches nothing, although the User Guide says search is not case-sensitive; "%" and "\_" act as wildcards; a request with no search-text field reaches the generic error page.

## Capabilities

### New Capabilities

- `catalog-search`: keyword search over the catalog and the screens that request and present it.

### Modified Capabilities

- none

## Impact

- Three requirements are approved and carry keys (SWHR5-R-0021, SWHR5-R-0020, SWHR5-R-0014). The remaining requirements are drafts awaiting SME decisions; recommendations are in `legacy-analysis/ir/_recommendations/catalog-search.yaml`.
- The case-sensitivity conflict between the User Guide and the running code goes to Intent for the Business Owner.
- Item pages (the result link target) and the general catalog paging rule belong to `catalog-browsing`. This capability depends on them and does not specify them.
