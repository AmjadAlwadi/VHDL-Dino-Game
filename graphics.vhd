library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.ALL;

-- bottom left origin

entity graphics is
    port (
        game_over_i        : in STD_ULOGIC;
        dino_y_i     : in unsigned (9 downto 0);
        obstacle_x_i : in unsigned (9 downto 0);
        obstacle_x_1_i : in unsigned (9 downto 0);
        h_pos_i  : in unsigned (9 downto 0);
        v_pos_i  : in unsigned (9 downto 0);
        r_o             : out std_logic_vector(3 downto 0);
        g_o             : out std_logic_vector(3 downto 0);
        b_o             : out std_logic_vector(3 downto 0)
    );
    

    
    constant screen_width     : unsigned (9 downto 0) := to_unsigned(640, 10);
    constant screen_height    : unsigned (9 downto 0) := to_unsigned(480, 10);
    constant obstacle_width   : unsigned (9 downto 0) := to_unsigned(30, 10);
    constant obstacle_height  : unsigned (9 downto 0) := to_unsigned(60, 10);
    constant dino_width       : unsigned (9 downto 0) := to_unsigned(40, 10);
    constant dino_height      : unsigned (9 downto 0) := to_unsigned(90, 10);
    constant dino_x           : unsigned (9 downto 0) := to_unsigned(40, 10);   -- x position is always constant
    constant ground_level     : unsigned (9 downto 0) := to_unsigned(400, 10);

end entity;
    
architecture rtl of graphics is

    
begin

 

    draw : process(h_pos_i, v_pos_i) is
    begin
    
        if  game_over_i = '1' then
           
            r_o <= "0101";
            g_o <= "1111";
            b_o <= "0110";
            
            
        else
            
            
            -- dino
            if (h_pos_i >= dino_x and h_pos_i <= dino_x + dino_width and
                v_pos_i <= dino_y_i and v_pos_i >= dino_y_i - dino_height) then
    
                r_o <= "0000";
                g_o <= "1111";
                b_o <= "0000";
            
            -- obstacle 1
            elsif (h_pos_i >= obstacle_x_i and h_pos_i <= obstacle_x_i + obstacle_width and
                     v_pos_i <= ground_level and v_pos_i >= ground_level - obstacle_height) then
    
                r_o <= "1111";
                g_o <= "0000";
                b_o <= "0000";
                
                
            -- obstacle 2
            elsif (h_pos_i >= obstacle_x_1_i and h_pos_i <= obstacle_x_1_i + obstacle_width and
                     v_pos_i <= ground_level and v_pos_i >= ground_level - obstacle_height) then
    
                r_o <= "1111";
                g_o <= "0000";
                b_o <= "0000";
            
            
            -- ground
            elsif (v_pos_i >= ground_level) then
    
                r_o <= "0000";
                g_o <= "0000";
                b_o <= "0000";
                 
    
            -- background    
            else 
                
                r_o <= "0100";
                g_o <= "0100";
                b_o <= "0100";
                
            end if;
        
        end if;
        
    end process;
end architecture;
