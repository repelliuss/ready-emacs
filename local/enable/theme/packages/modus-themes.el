;;; modus-themes.el -*- lexical-binding: t; -*-

(defun ~modus-themes-increase-mode-line-height ()
  (modus-themes-with-colors
    (custom-set-faces
     ;; Add "padding" to the mode lines
     `(mode-line ((,c :box (:line-width 10 :color ,bg-mode-line-active))))
     `(mode-line-inactive ((,c :box (:line-width 10 :color ,bg-mode-line-inactive)))))))

(setup modus-themes
  (:load)
  (:set modus-themes-custom-auto-reload t
	   modus-themes-disable-other-themes t
	   modus-themes-bold-constructs nil
	   modus-themes-italic-constructs nil
	   modus-themes-mixed-fonts t
	   modus-themes-prompts '(ultrabold italic)
	   modus-themes-completions '((matches . (extrabold))
				      (selection . (ultrabold italic)))
	   modus-themes-org-blocks 'tinted-background
	   modus-themes-headings nil
	   modus-themes-variable-pitch-ui nil
	   modus-themes-common-palette-overrides '((border-mode-line-active unspecified)
						   (border-mode-line-inactive unspecified)
						   
						   (bg-mode-line-active bg-blue-intense)
						   (fg-mode-line-active fg-main)
						   
						   (bg-tab-bar bg-cyan-nuanced)
						   (bg-tab-current bg-cyan-intense)
						   (bg-tab-other bg-cyan-subtle)
						   
						   (fringe unspecified)

						   (underline-link border)
						   (underline-link-visited border)
						   (underline-link-symbolic border)

						   (fg-prompt cyan-faint)
						   (bg-prompt unspecified)

						   (fg-completion-match-0 fg-main)
						   (fg-completion-match-1 fg-main)
						   (fg-completion-match-2 fg-main)
						   (fg-completion-match-3 fg-main)
						   (bg-completion-match-0 bg-blue-subtle)
						   (bg-completion-match-1 bg-yellow-subtle)
						   (bg-completion-match-2 bg-cyan-subtle)
						   (bg-completion-match-3 bg-red-subtle)
						   
						   (comment yellow-cooler)
						   (string green-cooler)

						   (bg-paren-match bg-magenta-intense)

						   (bg-button-active bg-main)
						   (fg-button-active fg-main)
						   (bg-button-inactive bg-inactive)
						   (fg-button-inactive "gray50")
						   
						   (prose-done green-intense)
						   (prose-todo red-intense)

						   (fg-heading-1 blue-warmer)
						   (fg-heading-2 yellow-cooler)
						   (fg-heading-3 cyan-cooler)
						   
						   (date-common cyan)   ; default value (for timestamps and more)
						   (date-deadline red-warmer)
						   (date-event magenta-warmer)
						   (date-holiday blue) ; for M-x calendar
						   (date-now yellow-warmer)
						   (date-scheduled magenta-cooler)
						   (date-weekday cyan-cooler)
						   (date-weekend blue-faint)

						   (mail-cite-0 blue)
						   (mail-cite-1 yellow)
						   (mail-cite-2 green)
						   (mail-cite-3 magenta)
						   (mail-part magenta-cooler)
						   (mail-recipient cyan)
						   (mail-subject red-warmer)
						   (mail-other cyan-cooler)

						   (bg-region bg-ochre) ; try to replace `bg-ochre' with `bg-lavender', `bg-sage'
						   (fg-region unspecified))
	   (append* modus-themes-common-palette-overrides) modus-themes-preset-overrides-intense)
  (~theme-load-if-preferred 'modus-themes 'modus-operandi 'modus-vivendi)
  ;; (~modus-themes-increase-mode-line-height)
  )

