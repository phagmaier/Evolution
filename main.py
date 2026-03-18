import matplotlib.pyplot as plt
import sys

def read_data(filename):
    data = {}
    with open(filename, "r") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            label, values = line.split(":", 1)
            nums = [float(x) for x in values.split()]
            data[label] = nums
    return data

def plot_population(data, axes):
    epochs = range(len(data["Population"]))
    axes.plot(epochs, data["Population"], color="#2e86de", linewidth=1.5)
    axes.set_title("Population Over Time")
    axes.set_xlabel("Epoch")
    axes.set_ylabel("Agents")
    axes.grid(True, alpha=0.3)

def plot_births_deaths(data, axes):
    epochs = range(len(data["Births"]))
    axes.plot(epochs, data["Births"], color="#10ac84", linewidth=1.2, label="Births")
    axes.plot(epochs, data["Deaths"], color="#ee5253", linewidth=1.2, label="Deaths")
    axes.set_title("Births & Deaths Per Epoch")
    axes.set_xlabel("Epoch")
    axes.set_ylabel("Count")
    axes.legend()
    axes.grid(True, alpha=0.3)

def plot_energy_age(data, axes):
    epochs = range(len(data["Average Energy"]))
    ax2 = axes.twinx()
    l1 = axes.plot(epochs, data["Average Energy"], color="#ff9f43", linewidth=1.5, label="Avg Energy")
    l2 = ax2.plot(epochs, data["Average Age"], color="#5f27cd", linewidth=1.5, label="Avg Age")
    axes.set_title("Average Energy & Age")
    axes.set_xlabel("Epoch")
    axes.set_ylabel("Energy", color="#ff9f43")
    ax2.set_ylabel("Age (ticks)", color="#5f27cd")
    lines = l1 + l2
    axes.legend(lines, [l.get_label() for l in lines], loc="upper left")
    axes.grid(True, alpha=0.3)

def plot_genome_averages(data, axes):
    epochs = range(len(data["Average Aggression"]))
    genes = [
        ("Average Aggression", "#ee5253"),
        ("Average Greed", "#ff9f43"),
        ("Average Speed", "#10ac84"),
        ("Average Perception", "#2e86de"),
        ("Average Sociability", "#5f27cd"),
        ("Average Food Priority", "#c44569"),
    ]
    for label, color in genes:
        short = label.replace("Average ", "")
        axes.plot(epochs, data[label], color=color, linewidth=1.2, label=short)
    axes.set_title("Genome Averages Over Time")
    axes.set_xlabel("Epoch")
    axes.set_ylabel("Gene Value (0-1)")
    axes.set_ylim(-0.05, 1.05)
    axes.legend(loc="upper right", fontsize=8)
    axes.grid(True, alpha=0.3)

def plot_archetypes(data, axes):
    epochs = range(len(data["Predators"]))
    predators = data["Predators"]
    foragers = data["Foragers"]
    social = data["Social"]
    drifters = data["Drifters"]
    axes.stackplot(
        epochs, predators, foragers, social, drifters,
        labels=["Predator", "Forager", "Social", "Drifter"],
        colors=["#ee5253", "#10ac84", "#5f27cd", "#aaaaaa"],
        alpha=0.8,
    )
    axes.set_title("Archetype Composition Over Time")
    axes.set_xlabel("Epoch")
    axes.set_ylabel("Count")
    axes.legend(loc="upper right", fontsize=8)
    axes.grid(True, alpha=0.3)

def plot_archetype_proportions(data, axes):
    epochs = list(range(len(data["Predators"])))
    pops = data["Population"]
    labels = ["Predators", "Foragers", "Social", "Drifters"]
    colors = ["#ee5253", "#10ac84", "#5f27cd", "#aaaaaa"]
    proportions = []
    for key in labels:
        proportions.append([
            data[key][i] / pops[i] if pops[i] > 0 else 0
            for i in range(len(pops))
        ])
    axes.stackplot(epochs, *proportions, labels=labels, colors=colors, alpha=0.8)
    axes.set_title("Archetype Proportions Over Time")
    axes.set_xlabel("Epoch")
    axes.set_ylabel("Proportion")
    axes.set_ylim(0, 1)
    axes.legend(loc="upper right", fontsize=8)
    axes.grid(True, alpha=0.3)

def main():
    filename = sys.argv[1] if len(sys.argv) > 1 else "data.txt"
    data = read_data(filename)

    fig, axes = plt.subplots(3, 2, figsize=(16, 14))
    fig.suptitle("Evolutionary Grid Simulation", fontsize=16, fontweight="bold")

    plot_population(data, axes[0][0])
    plot_births_deaths(data, axes[0][1])
    plot_energy_age(data, axes[1][0])
    plot_genome_averages(data, axes[1][1])
    plot_archetypes(data, axes[2][0])
    plot_archetype_proportions(data, axes[2][1])

    plt.tight_layout()
    plt.savefig("results.png", dpi=150)
    plt.show()

if __name__ == "__main__":
    main()
