# GUI_tools
Graphical user interface tools for EEG visualisation, statistics, event labelling, pre-processing, etc.

1) Awakening fixer
  Used for checking/fixing awakening markers in serial awakening paradigm data, as well as highlighting remaining bad epochs, and labelling K-complexes (KC), Vertex potentials (VP), delta waves, frontal spindles, and partietal spindles.

2) ERP viewer
  Used for visualising sensory-evoked potentials in different sleep stages. Select from different vigilance states (W, N1, N2, N3, R) and different stimulus modalities (visual, auditory, tactile). Select between "all trials" and only those containing detected slow waves. Click on ERP plot to change to that timepoint, click on topography to change to that channel. Statistics are typically comparing to zero - i.e., one-sample t-test.

3) Channel interpolater
   Used for manual interpolation of high-density EEG channels, based on various features: power in traditional bands, correlation with neighbours, amplitude z-scored to neighbours. Select feature of interest and vigilance state of interest (W, N1, N2, N3, R). Click channel with left-mouse to set for interpolation, click with right-mouse to select channels for time-domain visualisation. click iterate to interpolate channels, and to re-calculate features.

NOTE: tools are currently tailored to our specific data, but will be generalised soon!.. 
