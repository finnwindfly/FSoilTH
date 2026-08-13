# Process hierarchy

FSoilTH uses named configurations to separate the verified core from optional research complexity.

| Configuration | Added processes | Scientific purpose | Status |
|---|---|---|---|
| **FSoilTH** | Liquid water, heat and freeze–thaw | Conservative frozen-soil core | Planned M1 |
| **FSoilTH-V** | Water-vapor diffusion and phase-change source terms | Test vapor importance | Planned M3 |
| **FSoilTH-VA** | Dry-air mass balance and gas-pressure transport | Test air-pressure effects | Planned M3 |
| **FSoilTH-M** | Ground ice and deformation | Frost heave and thaw settlement | Planned M4 |
| **FSoilTH-CLM** | Land-surface coupling interface | Scale transfer and global experiments | Planned M5 |

## Acceptance rule

Adding a process is not evidence that it matters. Each extension must demonstrate:

1. mass and energy conservation;
2. numerical convergence and stability;
3. success on process-specific analytical or experimental benchmarks;
4. observable improvement or a defensible mechanistic change;
5. quantified parameter sensitivity and computational cost.

The same forcing, soil parameters and evaluation variables should be used for ablation experiments across the hierarchy wherever physically meaningful.
