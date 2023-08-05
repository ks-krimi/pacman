model Pacman

global torus: true {
	file data <- csv_file('../includes/world.csv',',');
	
	list<environement> roads;
	list<string> ghost_names <- ["Red", "Cyan", "Orange"];
	list<rgb> ghost_colors <- [#red, #cyan, #orange];
	
	int number_max_of_pacman <- 1;
	int number_max_of_ghost <- 3;
	
	list<point> ghost_init_locations <- [
		environement[12, 15].location,
		environement[14, 15].location,
		environement[16, 15].location
	];
	
	point pacman_init_location <- environement[14, 18].location;
	
	init {
		matrix data_grid <- matrix(data);
		ask environement {
			grid_value <- float(data_grid[grid_x, grid_y]);
			color <- grid_value = 1 ? #white : #gray;
		}
		
		roads <- environement where (each.grid_value = 1);
		
		do create_food;
		
		loop position over: ghost_init_locations {
			int index <- ghost_init_locations index_of position;
			create Ghost number: 1 {
				location <- position;
				name <- ghost_names[index];
				color <- ghost_colors[index];
			}
		}

		loop while: length(Pacman) < number_max_of_pacman {
			create Pacman number: 1 with: (location: location) {
				my_cell <- environement(location);
			}
		}
	}
	
	action create_food {
		create Food with: (location: one_of(roads).location) {
			set location <- location;
		}
	}
	
	reflex new_one when: length(Food) = 0  {
		do create_food;
	}
	
	reflex halting when: empty (Pacman) {
        ask host {
            do die;
        }
    }
}

grid environement width: 30 height: 32 {}

species name: Ghost skills: [moving] {
	Pacman pacman;
	rgb color;
	
	init {
		speed <- 0.7;
	}
	
	aspect name: default {
		draw circle(1.5) color: color;
	}
	
	reflex name: find_pacman when: pacman=nil {
		ask Pacman {
			myself.pacman <- self;
		}
	}
	
	action follow_pacman {
		if  (pacman!=nil) {
		do goto target: pacman on: roads;
		}
	}
	
	reflex when: after(starting_date + 15#s) {
		if (self.name = "Red") {
			do follow_pacman;
		}
	}
	
	reflex when: after(starting_date + 1#mn) {
		if (self.name = "Cyan") {
			do follow_pacman;
		}
	}
	
	reflex when: after(starting_date + 2#mn) {
		if (self.name = "Orange") {
			do follow_pacman;
		}
	}
}

species name: Pacman skills: [moving] {

	Food food;
	Ghost ghost;
	environement my_cell;

	init {
		speed <- 0.7;
		location <- pacman_init_location;
	}

	aspect name: default {
		draw circle(1.5) color: #yellow;
	}

	reflex name: find_food when: food=nil {
		ask Food {
			myself.food <- self;
		}
	}

	reflex name: move  when: food!=nil {
		my_cell <- get_location();
		do goto target: food on: roads;
	}

	reflex name: avoid_ghost {
		do move bounds: ghost;
	}

	reflex name: eat {
		do eat;
		set food <- nil;
	}

	reflex name: died {
		list<Ghost> ghosts <- Ghost inside (my_cell);
		if(!empty(ghosts)) {
			ask self {
				do die;
			}
		}
	}
	
	action eat {
		list<Food> foods <- Food inside (my_cell);
		if(!empty(foods)) {
			ask one_of (foods) {
				do die;
			}
		}
	}

	environement get_location {
		return environement({location.x, location.y});
	}
}

species Food {
	aspect default {
		draw circle(1) color: #green;
	}
}

experiment Run type: gui {
	output {
		display "Game World" {
			grid environement; 
			species Food aspect: default;
			species Pacman aspect: default;
			species Ghost aspect: default;
		}
	}
}
