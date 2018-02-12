INCLUDE job
INCLUDE intro.zone
INCLUDE tavern.zone
INCLUDE townsquare.zone
INCLUDE cutpursealley.zone
INCLUDE jobsimulator
INCLUDE define
INCLUDE conversations



LIST gameMode = intro, game, pause, questing, home, kidnapped, runaway
LIST gameTimeState = day=-1, night=1
VAR gameTime = day
VAR gameDays = 1
VAR gameDaysMax = 30

VAR debug = true

VAR latestID = 1000
VAR latestName = neri
VAR latestNameLast = "Manhke"
VAR latestNameTitle = ""
VAR latestJob = ()
VAR latestJobStatus = home
VAR latestJobTime = ()
VAR latestResult = ()
VAR latestTag = (orkStink, cumCovered, assGaped,pussyGaped)
VAR latestTagDay1 = (assGaped)
VAR latestTagDay2 = (cumCovered)
VAR latestTagDay3 = ()
VAR latestTagDay4 = (orkStink)
VAR latestTagDay5 = ()
VAR latestTagDay6 = ()
VAR latestTagDay7 = ()

+[skip intro] -> Game
+[don't skip intro]

-> Introduction -> Game

=== Game ===
{gameTime==day:Day <<{gameDays}>>}
// {define(gameTime,name)}time
{latestJobStatus==home:Selected: {define(latestName,name)} {latestNameLast}}
-(mainmenu)
    + (job) {latestJobStatus==home} [{jobBank:Job}{not jobBank:No Jobs...}]
            {not jobBank: Consider taking to towns people to find jobs for your Guild Members. -> mainmenu }
            <- popList(jobBank,-> mainmenu)
            <- goBack(-> mainmenu)    
            
    + {latestJobStatus==home}[{define(latestName,name)}]
        {define(latestName,name)} "{define(latestName,greeting)}"
        - - - - - (guildie)
        // + + {latestJob} [Talk Job]
        //     ~temp div = define(latestJob,divert)
        //     -> latestResult ->
        //     ~latestJob = ()
        //     -> guildie
        + + [Talk]
            ~temp guildietalk = define(latestName,talk)
            -> guildietalk -> guildie
        + + [Inspect]
            ~inspectMember(1000)
            -> guildie
        + + {debug} [Flags]
            Guildie Status: {displayTags(latestTag)}
            -> guildie
        + + [Back] -> mainmenu

    + (visit) [Visit]
        + + [Tavern] -> Tavern ->
        + + [Town Square] -> TownSquare ->
        + + [Cut Purse Alley] -> CutPurseAlley ->
        + + {TURNS_SINCE(-> TownSquare.back) <= 0} [{TURNS_SINCE(-> TownSquare.back)} Return Home] ->ReturnHome(true)-> CycleDay -> Game
        + + {TURNS_SINCE(-> TownSquare.back) > 0} [{TURNS_SINCE(-> TownSquare.back)} Back] -> mainmenu
        - - -> ReturnHome(false) -> CycleDay  -> Game
    + [{gameTime==night:Sleep}{gameTime==day:Nap}]
        -> CycleDay -> Game

=== ReturnHome(skip) ===
{skip:->skipchoice}
+ (skipchoice) [Return Home]
You {~make your way|return} home.
->->

=== function inspectMember (id) ===
~temp count = LIST_COUNT(latestTag)
~temp taglist = latestTag
{define(latestName,name)} is in good spirits
    {count>1:<>, {~considering|although|even though}}
    {taglist ? (assGaped,pussyGaped):
        <> {count>1:s|S}he seems {~uncomfotable while sitting|to take longer than usual to sit down}.
    }
    {taglist ? cumCovered:
        <> {count>1:A|a} thin film of {~semen|cum|goo} covers her {~body|skin}.
    }
    {latestTag ? orkStink:
        {count<=1:<>, but {~honestly, t|frankly, t|t}<>|{~Honestly, t|Frankly, t|T}<>}
        
        he {latestTag ? orkStink:Ork} {~stench|odor|smell|stink} {~eminating|wafting|drifting} off of her body could <>
        {~kill a yak at 10 paces|bring down a dragon|peel the bark off a tree}.
    }


=== function inspectMemberCycle (id,taglist) ===
~temp sitweird = (assGaped,pussyGaped)
    {LIST_COUNT(taglist)>1:{latestName} is in good spirits}
    {LIST_COUNT(taglist)>1:<>, {~considering|although|even though}}
    {taglist ^ sitweird:
        <> {LIST_COUNT(taglist)>=1:s|S}he seems {~uncomfotable while sitting|to take longer than usual to sit down}.
        ~taglist-=LIST_MIN(taglist^sitweird)
    }
    {taglist ? cumCovered:
        <> {LIST_COUNT(latestTag)>1:A|a} thin film of {~semen|cum|goo} covers her {~body|skin}.
        ~taglist-=cumCovered
    }
    {taglist ? orkStink:
        {LIST_COUNT(latestTag)<=1:<>, but {~honestly, t|frankly, t|t}<>|{~Honestly, t|Frankly, t|T}<>}
        he {latestTag ? orkStink:Ork} {~stench|odor|smell|stink} {~eminating|wafting|drifting} off of her body could <>
        {~kill a yak at 10 paces|bring down a dragon|peel the park off a tree}.
        ~taglist-=orkStink
    }
{taglist and id>0:
  ~id-=250
  Also, 
  ~inspectMemberCycle(id, taglist)
}
~return







=== CycleDay ===
~temp advancetime = advanceGameTime()
//{advancetime: Day <<{gameDays}>> }
{latestJob != ():
    ~latestJobTime+= -0.5
    Job Time Left: {latestJobTime}
    {latestJobTime <= 0:
        Your guildie returned.
        ~temp div = define(latestJob,divert)
        -> latestResult ->
        ~ latestJobStatus = home
        ~ jobBank -= latestJob
        ~ latestJob = ()
        //~ latestJob = ()
        //~ latestResult = ""
    }
-else:
    {advancetime: {stateCleanse(latestTag,sleep)} }
    {advancetime: {cleanseTagTime(latestTag,1)} }
}
->->

=== function stateCleanse(ref taglist,tagtype) ===
~temp cleanser = cleanseTag(taglist,tagtype)
{cleanser != ():
        ~taglist -= cleanser
        {define(cleanser,name)} status has been removed.
}

=== function cleanseTagTime(ref taglist,count) ===
{count:
    -1: {tagTimeList(count):
        ~verbose("Removed: {define(tagTimeList(count),name)}  \<br\>")
        ~taglist -= tagTimeList(count)
        ~tagTimeListSub(count,tagTimeList(count))
        }
    -8: ~return
    -else:  
        {tagTimeList(count): 
            ~verbose("{count-1} Days left for: {define(tagTimeList(count),name)} \<br\>")
            ~tagTimeListAdd(count-1,tagTimeList(count))
            ~tagTimeListSub(count,tagTimeList(count))
        }
}
~count++
~cleanseTagTime(taglist,count)

=== function verbose (message) ===
{debug:{message}}

=== function tagTimeList (x) ===
{x:
    -1: ~return latestTagDay1
    -2: ~return latestTagDay2
    -3: ~return latestTagDay3
    -4: ~return latestTagDay4
    -5: ~return latestTagDay5
    -6: ~return latestTagDay6
    -7: ~return latestTagDay7
}
=== function tagTimeListSub (x,y) ===
{x:
    -1: ~latestTagDay1 -= y
    -2: ~latestTagDay2 -= y
    -3: ~latestTagDay3 -= y
    -4: ~latestTagDay4 -= y
    -5: ~latestTagDay5 -= y
    -6: ~latestTagDay6 -= y
    -7: ~latestTagDay7 -= y
}
=== function tagTimeListAdd (x,y) ===
{x:
    -1: ~latestTagDay1 += y
    -2: ~latestTagDay2 += y
    -3: ~latestTagDay3 += y
    -4: ~latestTagDay4 += y
    -5: ~latestTagDay5 += y
    -6: ~latestTagDay6 += y
    -7: ~latestTagDay7 += y
}


=== function cleanseTag(taglist,remover) ===
        {LIST_COUNT(taglist):
        - 0: ~return ()
        - else: {define(LIST_MIN(taglist),required) ? remover:
                ~return LIST_MIN(taglist)
            }
            ~ return cleanseTag(taglist - LIST_MIN(taglist), remover)
        }

=== function advanceGameTime ====
~gameTime = gameTimeState(LIST_VALUE(gameTime)*-1)
{gameTime == day:
    ~gameDays++
    {gameDays == gameDaysMax: 
        ~gameDays = 1
    }
    ~return true
}
~return false

=== goBack(-> returnto) ===
    + [Back] -> returnto

=== function nextChoice(ref choices)
        ~ choices -= LIST_MIN(choices)
        {LIST_COUNT(choices) != 0:
            ~ return true
        }

=== popList(choices,-> returnto) ===
    <- genChoice(LIST_MIN(choices),returnto)
    {nextChoice(choices):->popList(choices,returnto)}

= genChoice(entry,-> returnto)
    
    + (job)[{define(entry,name)}] 
        {define(entry,describe)}
        -(top)
        + + [Accept]
            {define(latestName,name)} will be gone for {define(entry,duration)} day{define(entry,duration)>1:s}.
            ~ latestJob = entry
            ~ latestJobStatus = questing
            ~ latestJobTime = define(entry,duration)
            ~ temp gotojob = define(entry,divert)
            -> gotojob.event ->
            -> returnto
            
        + + [Info]
            ~ displayJobRequirement(entry)
            Duration: {define(entry,duration)} day(s).
            + + + [Back] -> top
            
        + + [Back] -> returnto
    


































// You're first day as Adventures Guild Master. A prestigeous and rare title, you inherited from your uncle. You'd be more excited if he hadn't run the thing into the ground. Cobwebs and debt are your true inheritances unless you can turn this musty money pit around.

// Lucky you! You've inherited your uncle's Guild and Guild License. Having been employed as a factotum most most of your life, you jump at the chance to make something of yourself.  As you approach the guild house, your confidence vanishes. It's a dump. Still hoping to make the best of a bad situation you tidy up as best you can to atleast give the appearance of proper guild. Truth of the matter is Guild licenses are extremly hard to get. Few are given each year and they must be renewed. Unfortunately for you the renewal date is fast approaching at the end of this month. With one final broom push you take a much deserved break. 

// * Sit
// You decide to take a seat. Your mind wanders as you look up at the cobwebs hiding in every wich corner of the heavy beamed framed guild.

// ** Cobwebs
// The guild itself would be quite nice if it was maintained. The build is structurally sound, but it does need alot of money and love to attract even the basic adventurer.

// ** Guild
// Adventurers Guild's have existed for a very long time. Like most other guilds, they provide  protection for both guild members and those looking ot hire.


// You nod off from the exaustion. You mind dances with thought of gold, delicious food and beutiful women. A voice pierces through the dream. A tiny voice at that, audible still. You wake up and your eyes focus sharply into the darkness. There you can see a faint glimmer cut through ther musty air. You stand up and aproach the glimmer. The voice dissapears suddenly as your harken on last time to make out what it's saying. You walk towards the source of the glimmer. As you approach cautiously through the darkness your hands hits an unfamiliar object. In near pitch blackness, your eyes adjust and you can make out a grandfather clock. A small door is visble at the base of the clock face. You reach out and open it but cannot find any proper method of opening the door. You notice a very dirty but familiar shape. It matches that of the Guild Token you inherited. You push the Token into it's coresponding pattern and a faint click is heard. There is a series of audible clicks signifying a hidden mechanism at play. Finally the whirling and clicks stop and you are in darkness. The door opens on it's own and out whizzes a spritely shape.

// Introduction to Guild Spirit Mee.

// Mee is 6 inches tall. Though she is humanoid in shape she is clearly not. Large glassy eyesm faint antenae, laarge unnaturally colored red hair and nearly naked save for a few stray bits of cloth. Mee introduces herself as the Guild's Spirit Guide. All successful guilds operate under the guidance of a spirit.


//   {name} returns with tussled hair and dirty clothes.
   
//   +{latestTags ^ cumCovered}[Why are you covered in goo?]
//     You interupt her before she can talk and grill her on her cum covered body. She flies into a tirade.
//   + [Let her talk]
//   -
//   {name}: "Ugh, that was the worst job EVER. First the Tavern Keeper had me shoveling- shoveling- shoveling excrement! In great big piles! The stench was so overwhelming I could barely breathe between gagging and sobbing. Oh, and top it all off there were these great big horses watching me with their beady little eyes." She takes a momment to shudder.
   
//   A-and between their legs was... oh gods, they were huge! 
   
//   +[Huge eh?]
// {name} They wouldn't stop bumping up against me with those big stinky things between their legs. And just when I thought I couldn't take it anymore, one of them had the audacity to finish, ON ME! It just kept coming and coming, with such force I thought I'd be knocked down in the filth. It was just too much, I tell you! <>

//   +[Eh skip that part] {name}: "Well suffice to say it was pretty gross. <>
//   -(skip)
//   I ran all the way here as fast as I could, I don't care if I don't get paid!" 

// +[Take the money]
    
// +[Allow her to keep it]

