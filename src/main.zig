const std = @import("std");
const builtin = @import("builtin");
const Constants = @import("constants.zig");

pub fn writeData(fileName: []const u8, data: *const Data, allocator: std.mem.Allocator) !void {
    var file = try std.fs.cwd().createFile(fileName, .{});
    defer file.close();
    var buf: [4096]u8 = undefined;
    var _writer = file.writer(&buf);
    const writer = &_writer.interface;

    try writeU32Line(writer, "Population:", data.pop, allocator);
    try writeU32Line(writer, "Births:", data.births, allocator);
    try writeU32Line(writer, "Deaths:", data.deaths, allocator);
    try writeF32Line(writer, "Average Energy:", data.avg_energy, allocator);
    try writeF32Line(writer, "Average Age:", data.avg_age, allocator);
    try writeF32Line(writer, "Average Aggression:", data.avg_aggression, allocator);
    try writeF32Line(writer, "Average Greed:", data.avg_greed, allocator);
    try writeF32Line(writer, "Average Speed:", data.avg_speed, allocator);
    try writeF32Line(writer, "Average Perception:", data.avg_perception, allocator);
    try writeF32Line(writer, "Average Sociability:", data.avg_sociability, allocator);
    try writeF32Line(writer, "Average Food Priority:", data.avg_food_priority, allocator);
    try writeU32Line(writer, "Predators:", data.num_predator, allocator);
    try writeU32Line(writer, "Foragers:", data.num_forager, allocator);
    try writeU32Line(writer, "Social:", data.num_social, allocator);
    try writeU32Line(writer, "Drifters:", data.num_drifter, allocator);
    try writer.flush();
}

fn writeU32Line(writer: anytype, label: []const u8, arr: []const u32, allocator: std.mem.Allocator) !void {
    _ = try writer.write(label);
    for (arr) |val| {
        const str = try std.fmt.allocPrint(allocator, " {d}", .{val});
        _ = try writer.write(str);
        allocator.free(str);
    }
    _ = try writer.write("\n");
}

fn writeF32Line(writer: anytype, label: []const u8, arr: []const f32, allocator: std.mem.Allocator) !void {
    _ = try writer.write(label);
    for (arr) |val| {
        const str = try std.fmt.allocPrint(allocator, " {d:.4}", .{val});
        _ = try writer.write(str);
        allocator.free(str);
    }
    _ = try writer.write("\n");
}

pub const Data = struct {
    pop: []u32,
    births: []u32,
    deaths: []u32,
    avg_energy: []f32,
    avg_age: []f32,
    avg_aggression: []f32,
    avg_greed: []f32,
    avg_speed: []f32,
    avg_perception: []f32,
    avg_sociability: []f32,
    avg_food_priority: []f32,
    num_predator: []u32,
    num_forager: []u32,
    num_social: []u32,
    num_drifter: []u32,

    pub fn init(epochs: usize, allocator: std.mem.Allocator) !Data {
        const pop = try allocator.alloc(u32, epochs);
        const births = try allocator.alloc(u32, epochs);
        const deaths = try allocator.alloc(u32, epochs);
        const avg_energy = try allocator.alloc(f32, epochs);
        const avg_age = try allocator.alloc(f32, epochs);
        const avg_aggression = try allocator.alloc(f32, epochs);
        const avg_greed = try allocator.alloc(f32, epochs);
        const avg_speed = try allocator.alloc(f32, epochs);
        const avg_perception = try allocator.alloc(f32, epochs);
        const avg_sociability = try allocator.alloc(f32, epochs);
        const avg_food_priority = try allocator.alloc(f32, epochs);
        const num_predator = try allocator.alloc(u32, epochs);
        const num_forager = try allocator.alloc(u32, epochs);
        const num_social = try allocator.alloc(u32, epochs);
        const num_drifter = try allocator.alloc(u32, epochs);
        for (0..epochs) |i| {
            pop[i] = 0;
            births[i] = 0;
            deaths[i] = 0;
            avg_energy[i] = 0;
            avg_age[i] = 0;
            avg_aggression[i] = 0;
            avg_greed[i] = 0;
            avg_speed[i] = 0;
            avg_perception[i] = 0;
            avg_sociability[i] = 0;
            avg_food_priority[i] = 0;
            num_predator[i] = 0;
            num_forager[i] = 0;
            num_social[i] = 0;
            num_drifter[i] = 0;
        }

        return .{
            .pop = pop,
            .births = births,
            .deaths = deaths,
            .avg_energy = avg_energy,
            .avg_age = avg_age,
            .avg_aggression = avg_aggression,
            .avg_greed = avg_greed,
            .avg_speed = avg_speed,
            .avg_perception = avg_perception,
            .avg_sociability = avg_sociability,
            .avg_food_priority = avg_food_priority,
            .num_predator = num_predator,
            .num_forager = num_forager,
            .num_social = num_social,
            .num_drifter = num_drifter,
        };
    }

    pub fn avg(self: *Data, epoch: u32) void {
        if (self.pop[epoch] == 0) return;
        const pop = @as(f32, @floatFromInt(self.pop[epoch]));
        self.avg_energy[epoch] /= pop;
        self.avg_age[epoch] /= pop;
        self.avg_aggression[epoch] /= pop;
        self.avg_greed[epoch] /= pop;
        self.avg_speed[epoch] /= pop;
        self.avg_perception[epoch] /= pop;
        self.avg_sociability[epoch] /= pop;
        self.avg_food_priority[epoch] /= pop;
    }

    pub fn deinit(self: *Data, allocator: std.mem.Allocator) void {
        allocator.free(self.pop);
        allocator.free(self.births);
        allocator.free(self.deaths);
        allocator.free(self.avg_energy);
        allocator.free(self.avg_age);
        allocator.free(self.avg_aggression);
        allocator.free(self.avg_greed);
        allocator.free(self.avg_speed);
        allocator.free(self.avg_perception);
        allocator.free(self.avg_sociability);
        allocator.free(self.avg_food_priority);
        allocator.free(self.num_predator);
        allocator.free(self.num_forager);
        allocator.free(self.num_social);
        allocator.free(self.num_drifter);
    }
};

pub const TileDistance = struct {
    tile: *Tile,
    row: usize,
    col: usize,
    pub fn init(tile: *Tile, row: usize, col: usize) TileDistance {
        return .{ .tile = tile, .row = row, .col = col };
    }
    pub fn calcDistance(self: *const TileDistance, loc: Location) f32 {
        const r1 = @as(f32, @floatFromInt(self.row));
        const c1 = @as(f32, @floatFromInt(self.col));
        const r2 = @as(f32, @floatFromInt(loc.row));
        const c2 = @as(f32, @floatFromInt(loc.col));
        const r = if (r1 > r2) (r1 - r2) else (r2 - r1);
        const c = if (c1 > c2) (c1 - c2) else (c2 - c1);
        return r + c;
    }
};

pub const Location = struct {
    row: usize,
    col: usize,
    pub fn init(row: usize, col: usize) Location {
        return .{ .row = row, .col = col };
    }
};

pub const Genome = struct {
    aggression: f32,
    greed: f32,
    speed: f32,
    perception: f32,
    sociability: f32,
    food_priority: f32,

    pub fn init(rand: std.Random) Genome {
        return .{
            .aggression = rand.float(f32),
            .greed = rand.float(f32),
            .speed = rand.float(f32),
            .perception = rand.float(f32),
            .sociability = rand.float(f32),
            .food_priority = rand.float(f32),
        };
    }
};

pub const Agent = struct {
    location: Location,
    genome: Genome,
    energy: u32,
    age: u16,

    pub fn init(row: usize, col: usize, rand: std.Random) Agent {
        return .{
            .location = Location.init(row, col),
            .genome = Genome.init(rand),
            .energy = Constants.STARTINGENERGY,
            .age = 0,
        };
    }

    pub fn addToAvg(self: *const Agent, data: *Data, epoch: u32) void {
        const genome = self.genome;
        data.pop[epoch] += 1;
        data.avg_age[epoch] += @as(f32, @floatFromInt(self.age));
        data.avg_energy[epoch] += @as(f32, @floatFromInt(self.energy));
        data.avg_aggression[epoch] += genome.aggression;
        data.avg_food_priority[epoch] += genome.food_priority;
        data.avg_greed[epoch] += genome.greed;
        data.avg_perception[epoch] += genome.perception;
        data.avg_sociability[epoch] += genome.sociability;
        data.avg_speed[epoch] += genome.speed;

        if (genome.aggression > 0.6) {
            data.num_predator[epoch] += 1;
        } else if (genome.food_priority > 0.6 and genome.sociability < 0.3) {
            data.num_forager[epoch] += 1;
        } else if (genome.sociability > 0.6) {
            data.num_social[epoch] += 1;
        } else data.num_drifter[epoch] += 1;
    }

    fn reproductionScore(self: *Agent) f32 {
        return self.genome.aggression + self.genome.sociability * @as(f32, @floatFromInt(self.energy));
    }

    pub fn hunger(self: *const Agent) u32 {
        return @as(u32, Constants.ENERGYCAP) -| self.energy;
    }

    fn scoreCell(self: *Agent, tile: *const Tile, distance: f32) f32 {
        const hasFood: f32 = if (tile.food) 1.0 else 0.0;
        const numAgents = @as(f32, @floatFromInt(tile.agents.items.len));
        return hasFood * self.genome.food_priority + numAgents * (self.genome.sociability + self.genome.aggression - 1.0) - distance * 0.1;
    }

    pub fn makePointer(allocator: std.mem.Allocator, row: usize, col: usize, rand: std.Random) !*Agent {
        const _agent = Agent.init(row, col, rand);
        const agent = try allocator.create(Agent);
        agent.* = _agent;
        return agent;
    }

    pub fn maxScore(self: *Agent, arr: std.ArrayList(TileDistance)) Location {
        var maxLoc: Location = self.location;
        var max: f32 = -1.0;
        for (arr.items) |item| {
            const distance = item.calcDistance(self.location);
            const score = self.scoreCell(item.tile, distance);
            if (score > max) {
                maxLoc = Location.init(item.row, item.col);
                max = score;
            }
        }
        return maxLoc;
    }

    fn move(self: *Agent, loc: Location, world: *World, allocator: std.mem.Allocator) !void {
        world.removeAgent(self.location, self);
        self.location = loc;
        try world.addAgent(self, allocator);
    }

    fn eat(self: *Agent, food: u32) void {
        self.energy = @min(self.energy + food, @as(u32, Constants.ENERGYCAP));
    }

    pub fn moveBest(self: *Agent, world: *World, allocator: std.mem.Allocator) !void {
        var arr = try self.scan(world, allocator);
        defer arr.deinit(allocator);
        const loc = self.maxScore(arr);
        try self.move(loc, world, allocator);
    }

    fn scan(self: *const Agent, world: *World, allocator: std.mem.Allocator) !std.ArrayList(TileDistance) {
        var arr = std.ArrayList(TileDistance).empty;
        const v = @as(isize, @intCast(self.getVision()));
        const r = @as(isize, @intCast(self.location.row));
        const c = @as(isize, @intCast(self.location.col));
        const rows = @as(isize, @intCast(world.rows));
        const cols = @as(isize, @intCast(world.cols));
        var dr: isize = -v;
        while (dr <= v) : (dr += 1) {
            var dc: isize = -v;
            while (dc <= v) : (dc += 1) {
                const nr = @mod(r + dr, rows);
                const nc = @mod(c + dc, cols);
                const row = @as(usize, @intCast(nr));
                const col = @as(usize, @intCast(nc));
                try arr.append(allocator, TileDistance.init(&world.grid[row][col], row, col));
            }
        }
        return arr;
    }

    pub fn maxMovement(self: *const Agent) u32 {
        return @intFromFloat(@round(1.0 + self.genome.speed * 2.0));
    }

    pub fn endTurn(self: *Agent) void {
        const speedDrain = self.maxMovement();
        const perceptionDrain = self.getVision() / 2;
        const total = @as(u32, Constants.ENERGYDRAIN) + speedDrain + perceptionDrain;
        if (total >= self.energy) {
            self.energy = 0;
        } else {
            self.energy -= total;
        }
        self.age += 1;
    }

    pub fn getVision(self: *const Agent) u32 {
        return @intFromFloat(@round(1.0 + self.genome.perception * 6.0));
    }
};

pub const Tile = struct {
    food: bool,
    agents: std.ArrayList(*Agent),
    pub fn init() Tile {
        return .{ .food = false, .agents = std.ArrayList(*Agent).empty };
    }
    pub fn addAgent(self: *Tile, agent: *Agent, allocator: std.mem.Allocator) !void {
        try self.agents.append(allocator, agent);
    }
    pub fn removeAgent(self: *Tile, agent: *const Agent) void {
        for (self.agents.items, 0..self.agents.items.len) |item, i| {
            if (agent == item) {
                self.agents.items[i] = self.agents.items[self.agents.items.len - 1];
                _ = self.agents.pop();
                return;
            }
        }
    }

    pub fn takeActions(self: *Tile, game: *Game) !void {
        const agents = self.agents.items;
        const pop = self.agents.items.len;
        if (pop == 0) return;

        if (pop == 1 and self.food) {
            var agent = agents[0];
            agent.eat(@as(u32, Constants.EAT));
        } else if (self.food and pop > 1) {
            if (pop > @as(usize, Constants.EAT)) {
                self.compete(game.rand);
            } else {
                var willShare = true;
                for (agents) |agent| {
                    const r = game.rand.float(f32);
                    if (r < agent.genome.greed) {
                        willShare = false;
                        self.compete(game.rand);
                        break;
                    }
                }
                if (willShare) self.share();
            }
        }
        if (pop > 1) {
            for (agents) |agent| {
                if (game.rand.float(f32) < agent.genome.aggression) {
                    self.fight(game.rand);
                    break;
                }
            }
            try self.reproduce(game);
        }
        self.food = false;
    }

    fn insertInOrder(allocator: std.mem.Allocator, agents: *std.ArrayList(*Agent), agent: *Agent) !void {
        try agents.append(allocator, agent);
        var arr = agents.items;
        var idx = arr.len - 1;
        while (idx > 0 and arr[idx].reproductionScore() > arr[idx - 1].reproductionScore()) {
            const tmp = arr[idx];
            arr[idx] = arr[idx - 1];
            arr[idx - 1] = tmp;
            idx -= 1;
        }
    }

    fn reproduce(self: *Tile, game: *Game) !void {
        var breeders = std.ArrayList(*Agent).empty;
        defer breeders.deinit(game.allocator);
        for (self.agents.items) |agent| {
            if (agent.energy >= Constants.REPRODUCE) try insertInOrder(game.allocator, &breeders, agent);
        }
        if (breeders.items.len < 2) return;
        var idx: usize = 0;
        const max = breeders.items.len - 1;
        while (idx < max) : (idx += 2) {
            const male = breeders.items[idx];
            const female = breeders.items[idx + 1];
            const agent = try breed(male, female, game.rand, game.allocator);
            game.data.births[game.epoch] += 1;
            try game.agents.append(game.allocator, agent);
            try game.world.addAgent(agent, game.allocator);
        }
    }

    fn breed(male: *Agent, female: *Agent, rand: std.Random, allocator: std.mem.Allocator) !*Agent {
        var morF = rand.boolean();
        var r = rand.intRangeAtMost(u8, 1, 10);
        var aggression = if (morF) male.genome.aggression else female.genome.aggression;
        aggression += if (r != 1) 0.0 else (rand.float(f32) - 0.5) * 0.2;
        aggression = @max(0.0, @min(1.0, aggression));

        morF = rand.boolean();
        r = rand.intRangeAtMost(u8, 1, 10);
        var greed = if (morF) male.genome.greed else female.genome.greed;
        greed += if (r != 1) 0.0 else (rand.float(f32) - 0.5) * 0.2;
        greed = @max(0.0, @min(1.0, greed));

        morF = rand.boolean();
        r = rand.intRangeAtMost(u8, 1, 10);
        var speed = if (morF) male.genome.speed else female.genome.speed;
        speed += if (r != 1) 0.0 else (rand.float(f32) - 0.5) * 0.2;
        speed = @max(0.0, @min(1.0, speed));

        morF = rand.boolean();
        r = rand.intRangeAtMost(u8, 1, 10);
        var perception = if (morF) male.genome.perception else female.genome.perception;
        perception += if (r != 1) 0.0 else (rand.float(f32) - 0.5) * 0.2;
        perception = @max(0.0, @min(1.0, perception));

        morF = rand.boolean();
        r = rand.intRangeAtMost(u8, 1, 10);
        var sociability = if (morF) male.genome.sociability else female.genome.sociability;
        sociability += if (r != 1) 0.0 else (rand.float(f32) - 0.5) * 0.2;
        sociability = @max(0.0, @min(1.0, sociability));

        morF = rand.boolean();
        r = rand.intRangeAtMost(u8, 1, 10);
        var food_priority = if (morF) male.genome.food_priority else female.genome.food_priority;
        food_priority += if (r != 1) 0.0 else (rand.float(f32) - 0.5) * 0.2;
        food_priority = @max(0.0, @min(1.0, food_priority));

        const agent = try allocator.create(Agent);
        agent.* = .{
            .genome = .{
                .food_priority = food_priority,
                .aggression = aggression,
                .greed = greed,
                .perception = perception,
                .sociability = sociability,
                .speed = speed,
            },
            .energy = Constants.CHILDENERGY,
            .location = male.location,
            .age = 0,
        };
        male.energy -|= Constants.COSTREPRODUCTION;
        female.energy -|= Constants.COSTREPRODUCTION;
        return agent;
    }

    fn fight(self: *Tile, rand: std.Random) void {
        if (self.agents.items.len < 2) return;
        var max1: f32 = 0;
        var one: ?*Agent = null;
        var max2: f32 = 0;
        var two: ?*Agent = null;
        for (self.agents.items) |agent| {
            const int = @as(f32, @floatFromInt(rand.intRangeAtMost(u8, 0, 1)));
            const random = rand.float(f32) + int;
            const score = agent.genome.aggression * @as(f32, @floatFromInt(agent.energy)) * random;
            if (score > max1) {
                max2 = max1;
                two = one;
                max1 = score;
                one = agent;
            } else if (score > max2) {
                max2 = score;
                two = agent;
            }
        }
        const winner = one orelse return;
        const loser = two orelse return;
        winner.eat(@as(u32, Constants.FIGHT));
        loser.energy = if (loser.energy < Constants.FIGHT) 0 else loser.energy - Constants.FIGHT;
        if (loser.energy == 0) winner.eat(@as(u32, Constants.KILLBONUS));
    }

    fn compete(self: *Tile, rand: std.Random) void {
        if (self.agents.items.len < 2) return;
        var max1: f32 = 0;
        var one: ?*Agent = null;
        var max2: f32 = 0;
        var two: ?*Agent = null;
        for (self.agents.items) |agent| {
            const int = @as(f32, @floatFromInt(rand.intRangeAtMost(u8, 0, 1)));
            const random = rand.float(f32) + int;
            const score = agent.genome.aggression * @as(f32, @floatFromInt(agent.energy)) * random;
            if (score > max1) {
                max2 = max1;
                two = one;
                max1 = score;
                one = agent;
            } else if (score > max2) {
                max2 = score;
                two = agent;
            }
        }
        const winner = one orelse return;
        const loser = two orelse return;
        winner.eat(@as(u32, Constants.EAT));
        loser.energy = if (loser.energy < Constants.LOSE) 0 else loser.energy - Constants.LOSE;
    }

    fn share(self: *Tile) void {
        const pop: u32 = @intCast(self.agents.items.len);
        if (pop == 0) return;
        const total: u32 = @as(u32, Constants.EAT);
        const division = total / pop;
        var leftovers = total - division * pop;
        for (self.agents.items) |agent| {
            const tmp = agent.energy + division;
            leftovers += if (tmp <= @as(u32, Constants.ENERGYCAP)) 0 else tmp - @as(u32, Constants.ENERGYCAP);
            agent.eat(division);
        }
        for (self.agents.items) |agent| {
            const h = agent.hunger();
            if (h > 0 and leftovers > 0) {
                const give = @min(h, leftovers);
                agent.eat(give);
                leftovers -= give;
                if (leftovers == 0) break;
            }
        }
    }

    pub fn isOccupied(self: *const Tile) bool {
        return self.agents.items.len > 0;
    }
};

pub const World = struct {
    rand: std.Random,
    grid: [][]Tile,
    rows: usize,
    cols: usize,

    pub fn init(allocator: std.mem.Allocator, rand: std.Random, rows: usize, cols: usize) !World {
        var grid = try allocator.alloc([]Tile, rows);
        for (0..rows) |i| {
            grid[i] = try allocator.alloc(Tile, cols);
        }
        for (0..rows) |row| {
            for (0..cols) |col| {
                grid[row][col] = Tile.init();
            }
        }
        for (0..Constants.FOODPERTICK) |_| {
            var row = rand.intRangeAtMost(usize, 0, rows - 1);
            var col = rand.intRangeAtMost(usize, 0, cols - 1);
            while (grid[row][col].food) {
                row = rand.intRangeAtMost(usize, 0, rows - 1);
                col = rand.intRangeAtMost(usize, 0, cols - 1);
            }
            grid[row][col].food = true;
        }
        return .{ .rand = rand, .grid = grid, .rows = rows, .cols = cols };
    }

    pub fn isOccupied(self: *const World, row: usize, col: usize) bool {
        return self.grid[row][col].isOccupied();
    }

    pub fn spawnFood(self: *World, allocator: std.mem.Allocator) !void {
        var grid = self.grid;
        var cells = std.ArrayList(Location).empty;
        defer cells.deinit(allocator);
        for (0..self.rows) |row| {
            for (0..self.cols) |col| {
                if (!grid[row][col].food) try cells.append(allocator, Location.init(row, col));
            }
        }
        const genSize = @min(cells.items.len, @as(usize, Constants.FOODPERTICK));
        for (0..genSize) |_| {
            const idx = self.rand.intRangeAtMost(usize, 0, cells.items.len - 1);
            const loc = cells.items[idx];
            grid[loc.row][loc.col].food = true;
            cells.items[idx] = cells.items[cells.items.len - 1];
            _ = cells.pop();
        }
    }

    pub fn removeAgent(self: *World, loc: Location, agent: *const Agent) void {
        self.grid[loc.row][loc.col].removeAgent(agent);
    }
    pub fn addAgent(self: *World, agent: *Agent, allocator: std.mem.Allocator) !void {
        try self.grid[agent.location.row][agent.location.col].addAgent(agent, allocator);
    }

    pub fn deinit(self: *World, allocator: std.mem.Allocator) void {
        for (0..self.rows) |i| {
            allocator.free(self.grid[i]);
        }
        allocator.free(self.grid);
    }
};

pub const Game = struct {
    allocator: std.mem.Allocator,
    rand: std.Random,
    world: World,
    agents: std.ArrayList(*Agent),
    epoch: u32,
    maxEpochs: u32,
    data: Data,

    pub fn init(allocator: std.mem.Allocator, rand: std.Random, rows: usize, cols: usize, numAgents: usize, maxEpochs: u32) !Game {
        std.debug.assert(numAgents < (rows * cols) / 2);
        var agents = std.ArrayList(*Agent).empty;
        var world = try World.init(allocator, rand, rows, cols);
        for (0..numAgents) |_| {
            var row = rand.intRangeAtMost(usize, 0, rows - 1);
            var col = rand.intRangeAtMost(usize, 0, cols - 1);
            while (world.isOccupied(row, col)) {
                row = rand.intRangeAtMost(usize, 0, rows - 1);
                col = rand.intRangeAtMost(usize, 0, cols - 1);
            }
            const agent = try Agent.makePointer(allocator, row, col, rand);
            try agents.append(allocator, agent);
            try world.addAgent(agent, allocator);
        }
        return .{
            .allocator = allocator,
            .rand = rand,
            .world = world,
            .agents = agents,
            .epoch = 0,
            .maxEpochs = maxEpochs,
            .data = try Data.init(maxEpochs, allocator),
        };
    }

    pub fn play(self: *Game) !void {
        for (0..self.maxEpochs) |_| {
            try self.tick();
        }
    }

    fn tick(self: *Game) !void {
        try self.world.spawnFood(self.allocator);
        self.rand.shuffle(*Agent, self.agents.items);
        for (self.agents.items) |agent| {
            try agent.moveBest(&self.world, self.allocator);
        }
        for (self.world.grid) |*row| {
            for (row.*) |*tile| {
                if (tile.isOccupied()) {
                    try tile.takeActions(self);
                }
            }
        }
        try self.endTurnCleanup();
    }

    fn endTurnCleanup(self: *Game) !void {
        var count: usize = 0;
        while (count < self.agents.items.len) {
            var agent = self.agents.items[count];
            agent.endTurn();
            if (agent.energy == 0 or agent.age >= Constants.MAXAGE) {
                self.delAgent(count, agent);
                self.data.deaths[self.epoch] += 1;
            } else {
                count += 1;
                agent.addToAvg(&self.data, self.epoch);
            }
        }
        self.data.avg(self.epoch);
        self.epoch += 1;
    }

    fn delAgent(self: *Game, index: usize, agent: *Agent) void {
        const loc = agent.location;
        self.world.removeAgent(loc, agent);
        self.allocator.destroy(self.agents.items[index]);
        self.agents.items[index] = self.agents.items[self.agents.items.len - 1];
        _ = self.agents.pop();
    }

    pub fn deinit(self: *Game) void {
        self.world.deinit(self.allocator);
        for (self.agents.items) |agent| {
            self.allocator.destroy(agent);
        }
        self.agents.deinit(self.allocator);
        self.data.deinit(self.allocator);
    }
};

pub fn main() !void {
    var da = std.heap.DebugAllocator(.{}){};
    const allocator = if (builtin.mode == .Debug)
        da.allocator()
    else
        std.heap.smp_allocator;

    var prng: std.Random.DefaultPrng = .init(blk: {
        var seed: u64 = undefined;
        try std.posix.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    const rand = prng.random();

    //var game = try Game.init(allocator, rand, Constants.ROWS, Constants.COLS, Constants.AGENTS, Constants.ITERATIONS);
    var game = try Game.init(allocator, rand, Constants.ROWS, Constants.COLS, Constants.AGENTS, 100000);
    defer game.deinit();
    try game.play();
    try writeData("data.txt", &game.data, allocator);
}
