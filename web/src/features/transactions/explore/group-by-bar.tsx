import { Figure } from "@/components/figure"
import { SegmentedControl } from "@/components/primitives"
import { Toggle } from "@/components/ui/toggle"

import type { GroupByMode } from "./pivot"
import { GROUP_BY_LABELS, GROUP_BY_MODES } from "./pivot"

const OPTIONS = GROUP_BY_MODES.map((mode) => ({
  value: mode,
  label: GROUP_BY_LABELS[mode],
}))

export function GroupByBar({
  mode,
  onModeChange,
  needsReview,
  onNeedsReviewChange,
  loadedCount,
  totalResults,
}: {
  mode: GroupByMode
  onModeChange: (mode: GroupByMode) => void
  needsReview: boolean
  onNeedsReviewChange: (needsReview: boolean) => void
  loadedCount: number
  totalResults: number | undefined
}) {
  return (
    <div
      data-slot="group-by-bar"
      className="flex flex-wrap items-center gap-[10px] px-0.5 pt-[18px] pb-[11px]"
    >
      <span className="flex-none text-[11.5px] leading-none font-medium text-ink-3">
        Group by
      </span>
      <SegmentedControl
        value={mode}
        onValueChange={onModeChange}
        options={OPTIONS}
        label="Group transactions by"
        size="sm"
      />
      <Toggle
        variant="outline"
        size="sm"
        pressed={needsReview}
        onPressedChange={onNeedsReviewChange}
        className="text-[11.5px]"
      >
        Needs review
      </Toggle>
      <span aria-hidden className="hidden flex-1 md:block" />
      <span className="flex items-baseline gap-[5px] text-[11.5px] leading-none whitespace-nowrap text-ink-3">
        <Figure value={loadedCount} kind="plain" intent="meta" size="micro" />
        {totalResults === undefined ? (
          "rows loaded"
        ) : (
          <>
            of{" "}
            <Figure
              value={totalResults}
              kind="plain"
              intent="meta"
              size="micro"
            />{" "}
            rows loaded
          </>
        )}
      </span>
    </div>
  )
}
