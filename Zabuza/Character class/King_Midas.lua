	--[[
King Midas - Created by Zabuza
v1.04
skill check - so it can only be activated if there is gold to convert to DMG

v1.03

Starting Cards 
4x Kings advicer
4x Midas gold
2x Liquid gold

Skill - Greed is good - turns gold into DMG
Ability - Golden Touch - Sacrifice all champions in play, converts them back into gold
]]
require 'herorealms'
require 'decks'
require 'stdlib'
require 'timeoutai'
require 'hardai_2'
require 'aggressiveai'


local function chooseTheClass()
    return cardChoiceSelectorEffect({
        id = "choose_the_class_king_midas",
        name = "Choose a class",
        trigger = startOfTurnTrigger,

        upperTitle  = "Choose a class",
        lowerTitle  = "",

        effectFirst = sacrificeTarget().apply(selectLoc(loc(currentPid, handPloc)).union(selectLoc(loc(currentPid, deckPloc))).union(selectLoc(loc(currentPid, skillsPloc))))
			.seq(setPlayerNameEffect("King Midas", currentPid))
			.seq(setPlayerAvatarEffect("profit", currentPid))
			.seq(gainMaxHealthEffect(currentPid, const(42).add(getPlayerMaxHealth(currentPid).negate())))
			.seq(gainHealthEffect(42))
			.seq(createCardEffect(greed_is_good_skilldef(), currentSkillsLoc))
			.seq(createCardEffect(golden_touch_abilitydef(), currentSkillsLoc))
			.seq(createCardEffect(midas_kings_advicer_carddef(), currentDeckLoc))
			.seq(createCardEffect(midas_kings_advicer_carddef(), currentDeckLoc))
			.seq(createCardEffect(midas_kings_advicer_carddef(), currentDeckLoc))
			.seq(createCardEffect(midas_kings_advicer_carddef(), currentDeckLoc))
			.seq(createCardEffect(midas_gold_carddef(), currentDeckLoc))
			.seq(createCardEffect(midas_gold_carddef(), currentDeckLoc))
			.seq(createCardEffect(midas_gold_carddef(), currentDeckLoc))
			.seq(createCardEffect(midas_gold_carddef(), currentDeckLoc))
			.seq(createCardEffect(midas_liquid_gold_carddef(), currentDeckLoc))
			.seq(createCardEffect(midas_liquid_gold_carddef(), currentDeckLoc))
			.seq(shuffleEffect(currentDeckLoc))
			.seq(waitForClickEffect("Thank you for choosing the King Midas class.", ""))
		.seq(waitForClickEffect("Your skill allows you to convert undspend gold into an equal amount of damage, at the cost of loosing a permanent health ponit.", ""))
		.seq(waitForClickEffect("Your abillity allows you to sacrifice all champions you have in play at the moment of use, you also regain their value in gold. Use it early game to get rid of your advicers or save it for an extra big swin in end game.", ""))
		.seq(waitForClickEffect("Remember to save to your favourites, and you will be able to host your own custom games using this script.", ""))
		.seq(waitForClickEffect("For game to begin normally please end turn now. And remeber to check out Realmrising.com or our discord for more content", "")),
        effectSecond = waitForClickEffect("Thank you for choosing your class.", "")
		.seq(waitForClickEffect("If you enjoy this game, be sure to Favourite the script.", ""))
		.seq(waitForClickEffect("Once the game ends, click back on the game record tile. An 'Add to Favourites' tile will have appeared alongside 'Replay' and 'Rematch'.", ""))
		.seq(waitForClickEffect("Once favourited, you will be able to host your own custom games using this script.", ""))
		.seq(waitForClickEffect("For game to begin normally please end turn now. And remeber to check out Realmrising.com for more content", "")),

        layoutFirst = createLayout({
            name = "King Midas",
            art = "art/T_Bribe",
            frame = "frames/Treasure_CardFrame",
            text = "Play as a level 3 King Midas."  }),

        layoutSecond = createLayout({
            name = "Selected class",
            art = "art/T_All_Heroes",
            text = "Play as the character you selected when setting up the game." }),

        turn = 1
    })
end

local function goFirstEffect()
	return createGlobalBuff({
        id="draw_three_start_buff",
        name = "Go First",
        abilities = {
            createAbility({
                id="go_first_draw_effect",
                trigger = endOfTurnTrigger,
                effect = ifElseEffect(
					getTurnsPlayed(oppPid).eq(1),
					nullEffect(),
					drawCardsEffect(2)
				)
            })
        }
    })
end





function setupGame(g)
	registerCards(g, {
		midas_kings_advicer_carddef(),
		greed_is_good_skilldef(),
		golden_touch_abilitydef(),
		midas_liquid_gold_carddef(),
		midas_gold_carddef(),
	})
	
    standardSetup(g, {
        description = "You have the Midas touch. Everything you touch turns to gold",
        playerOrder = { plid1, plid2 },
        ai = ai.CreateKillSwitchAi(createAggressiveAI(),  createHardAi2()),
        timeoutAi = createTimeoutAi(),
        opponents = { { plid1, plid2 } },
        players = {
            {
                id = plid1,
                startDraw = 0,
                init = {
                    fromEnv = plid1
                },
                cards = {
                    buffs = {
						drawCardsCountAtTurnEndDef(3),
						goFirstEffect(),
                        discardCardsAtTurnStartDef(),
						chooseTheClass(),
						fatigueCount(42, 1, "FatigueP1")
                    }
                }
            },
            {
                id = plid2,
                startDraw = 0,
				init = {
                    fromEnv = plid2
                },
                cards = {
                    buffs = {
                        drawCardsCountAtTurnEndDef(5),
                        discardCardsAtTurnStartDef(),
						chooseTheClass(),
						fatigueCount(42, 1, "FatigueP2")
                    }
                }
            }			
        }
    })
end

function midas_kings_advicer_carddef()
	return createChampionDef({
        id="midas_kings_advicer",
        name="Kings advicer",
        types={championType, priestType},
        acquireCost=1,
        health = 1,
        isGuard = false,
        abilities = {
			createAbility({
				id = "kingsAdvicerMain",
				trigger = autoTrigger,
				effect = gainGoldEffect(1),
				cost = expendCost,
				activations = multipleActivations
			})
		},
        layout = createLayout({
			name = "Kings advicer",
			art = "art/T_Tithe_Priest",
			frame = "frames/Treasure_CardFrame",
			text = "<i>Lean into the power of “No” to fend off the distractions of shiny new objects.</i>",
			xmlText = [[<vlayout forceheight="false" spacing="6">
    <hlayout spacing="10">
       <icon text="{expend}" fontsize="50"/>
<icon text="{gold_1}" fontsize="50"/>
    </hlayout>    
    <divider/>
    <hlayout forcewidth="true" spacing="10">
        <vlayout  forceheight="false">
<text fontstyle="italic" text="Lean into the power of 'No' to fend off the distractions of shiny new objects." fontsize="16"/>
        </vlayout>
    </hlayout>
</vlayout>]],
			health = 1,
			cost = 1,
			isGuard = false
        })
    })
end


function midas_gold_carddef()
	return createItemDef({
        id = "midas_gold",
        name = "Gold",
        types = { itemType, currencyType, coinType },
        acquireCost = 0,
        abilities = {
            createAbility({
                id = "midasGoldMain",
                effect = gainGoldEffect(1),
                cost = noCost,
                trigger = autoTrigger
            })
        },
        layout = createLayout({
			name = "Gold",
			art = "art/gold_male_pale",
			frame = "frames/Treasure_CardFrame",
			xmlText = [[<vlayout forceheight="false" spacing="6">
    <hlayout spacing="10">

<icon text="{gold_1}" fontsize="50"/>

</hlayout>
    <divider/>
    <hlayout forcewidth="true" spacing="10">
        <vlayout  forceheight="false">
<text fontstyle="italic" text="Gold is forever. It is beautiful, useful, and never wears out." fontsize="16"/>
        </vlayout>
    </hlayout>
</vlayout>]],
        })
    })
end

function midas_liquid_gold_carddef()
	return createItemDef({
        id = "midas_liquid_gold",
        name = "Liquid gold",
        types = { itemType, currencyType, coinType },
        acquireCost = 0,
        abilities = {
            createAbility({
                id = "midasLiquidGoldMain",
                effect = gainGoldEffect(2),
                cost = noCost,
                trigger = autoTrigger
            })
        },
        layout = createLayout({
			name = "Liquid gold",
			art = "art/treasures/T_Cleric_Elixir_Golden",
			frame = "frames/Treasure_CardFrame",
			xmlText = [[<vlayout forceheight="false" spacing="6">
    <hlayout spacing="10">

<icon text="{gold_2}" fontsize="50"/>

</hlayout>
    <divider/>
    <hlayout forcewidth="true" spacing="10">
        <vlayout  forceheight="false">
<text fontstyle="italic" text="Wine has never tasted better." fontsize="16"/>
        </vlayout>
    </hlayout>
</vlayout>]],
        })
    })
end



function greed_is_good_skilldef()
	return createSkillDef({
		id = "greed_is_good",
		name = "Greed is Good",
		cardTypeLabel = "Skill",
		types = { skillType },
        abilities = {
			createAbility({
				id = "GreedIsGoodActivate",
				trigger = uiTrigger,
				promptType = showPrompt,
				layout = createLayout({
					name = "Greed is good",
					art = "art/T_Bribe",
					frame = "frames/Treasure_CardFrame",
					text = "",
					xmlText = [[<vlayout forceheight="false" spacing="6">
									<hlayout spacing="5">
									   <icon text="{expend}" fontsize="55"/>
									   <text text="-{health_1} permanent health to convert all gold you have in play into damage." fontsize="18"/>
									</hlayout> 
									<divider/>
									<hlayout forcewidth="true" spacing="10">
										<vlayout  forceheight="false">
											 <text fontstyle="italic" text="Where Gold speaks, every tongue is silent." fontsize="14"/>
										</vlayout>
									</hlayout>
								</vlayout>]]
				}),
				effect = gainCombatEffect(getPlayerGold(currentPid).add(1)).seq(gainGoldEffect(getPlayerGold(currentPid).multiply(-1))).seq(gainHealthEffect(-1)).seq(gainMaxHealthEffect(currentPid, -1)) , 
				cost = combineCosts({ expendCost, goldCost(1) })
			})
		},
		layout = createLayout({
			name = "Greed is good",
			art = "art/T_Bribe",
			frame = "frames/Treasure_CardFrame",
			text = "",
			xmlText = [[<vlayout forceheight="false" spacing="6">
							<hlayout spacing="5">
							   <icon text="{expend}" fontsize="55"/>
							   <text text="-{health_1} permanent health to convert all gold you have in play into damage." fontsize="18"/>
							</hlayout> 
							<divider/>
							<hlayout forcewidth="true" spacing="10">
								<vlayout  forceheight="false">
									 <text fontstyle="italic" text="Where Gold speaks, every tongue is silent." fontsize="14"/>
								</vlayout>
							</hlayout>
						</vlayout>]]
		}),
		layoutPath= "art/T_Bribe"
	})
end	


function golden_touch_abilitydef()
	return createDef({
		id = "golden_touch",
		name = "Golden touch",
		acquireCost = 0,
		cardTypeLabel = "Ability",
		playLocation = skillsPloc,
		types = { heroAbilityType },
        abilities = {
			createAbility({
				id = "goldenTouchActivate",
				trigger = uiTrigger,
				promptType = showPrompt,
				layout = createLayout({
					name = "Golden touch",
					art = "art/T_Strength_In_Numbers",
					frame = "frames/Treasure_CardFrame",
					text = "",
					xmlText = [[
						<vlayout forceheight="false" spacing="6">
							<hlayout spacing="5">
								<icon text="{scrap}" fontsize="65"/>
								<text text="Sacrifice all champions you have in play and convert them back into gold." fontsize="20"/>
							</hlayout> 
						</vlayout>
					]]
				}),
				effect = gainGoldEffect(selectCurrentChampions().sum(getCardCost())).seq(sacrificeTarget().apply(selectCurrentChampions())),
				cost = sacrificeSelfCost
			})
		},
		layout = createLayout({
			name = "Golden touch",
			art = "art/T_Strength_In_Numbers",
			frame = "frames/Treasure_CardFrame",
			text = "",
			xmlText = [[
				<vlayout forceheight="false" spacing="6">
					<hlayout spacing="5">
						<icon text="{scrap}" fontsize="65"/>
						<text text="Sacrifice all champions you have in play and convert them back into gold." fontsize="20"/>
					</hlayout> 
				</vlayout>
			]]
		}),
		layoutPath= "art/T_Strength_In_Numbers"
	})
end	


function endGame(g)
end





function setupMeta(meta)
    meta.name = "King_Midas"
    meta.minLevel = 0
    meta.maxLevel = 3
    meta.introbackground = ""
    meta.introheader = ""
    meta.introdescription = ""
    meta.path = "C:/Users/glatk/Documents/HR - LUA/hero-realms-lua-scripts/Zabuza/Character class/King_Midas.lua"
     meta.features = {
}

end