// Final verification of the spiral algorithm
function generateGappedDiamondSpiral(segments, gap = 2) {
    const isEven = (segments % 2 === 0);
    const dirs = isEven ? [
        { dx: -1, dy: 1 },  // Down-Left (mirrored start)
        { dx: 1, dy: 1 },   // Down-Right
        { dx: 1, dy: -1 },  // Up-Right
        { dx: -1, dy: -1 }  // Up-Left
    ] : [
        { dx: 1, dy: 1 },   // Down-Right
        { dx: -1, dy: 1 },  // Down-Left
        { dx: -1, dy: -1 }, // Up-Left
        { dx: 1, dy: -1 }   // Up-Right
    ];

    let u = 0, v = 0;
    let points = [];
    points.push({ u, v });

    let dirIdx = 0;
    let currentLen = gap;

    for (let i = 0; i < segments; i++) {
        let dir = dirs[dirIdx];
        for (let j = 0; j < currentLen; j++) {
            u += dir.dx;
            v += dir.dy;
            points.push({ u, v });
        }
        dirIdx = (dirIdx + 1) % 4;
        if (dirIdx % 2 === 0) {
            currentLen += gap;
        }
    }

    let minX = Math.min(...points.map(p => p.u));
    let maxX = Math.max(...points.map(p => p.u));
    let minY = Math.min(...points.map(p => p.v));
    let maxY = Math.max(...points.map(p => p.v));

    let grid = [];
    for (let y = minY; y <= maxY; y++) {
        let rowStr = "";
        for (let x = minX; x <= maxX; x++) {
            if (Math.abs(x % 2) !== Math.abs(y % 2)) {
                rowStr += " ";
                continue;
            }
            if (points.some(p => p.u === x && p.v === y)) {
                rowStr += "*";
            } else {
                rowStr += " ";
            }
        }
        grid.push(rowStr);
    }

    // Build framed output
    let width = maxX - minX + 1;
    let top = "╔" + "═".repeat(width + 2) + "╗";
    let bottom = "╚" + "═".repeat(width + 2) + "╝";

    console.log("Segments = " + segments);
    console.log(top);
    grid.forEach(row => console.log("║ " + row + " ║"));
    console.log(bottom);
    console.log("");
}

generateGappedDiamondSpiral(4);
generateGappedDiamondSpiral(6);
generateGappedDiamondSpiral(8);
generateGappedDiamondSpiral(10);
generateGappedDiamondSpiral(14);
generateGappedDiamondSpiral(18);
