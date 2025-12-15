GeoSecure-B: A Method for Secure Bearing
Calculation
Vikram Patil1,2, Sharmilee Rajkumar Rajan2 and Pradeep K. Atrey2
1Albany Lab for Privacy and Security, University at Albany, SUNY, Albany, NY, USA
2GoDaddy LLC, Hoboken, NJ, USA
Email: vpatil@ieee.org, srajkumarrajan@albany.edu, patrey@albany.edu
Abstract—Location-Based Services (LBS) applications are ev-
erywhere these days. Detecting the heading or bearing is crucial
for many of these applications, as it indicates the direction
the user is moving. This information is typically derived from
the GPS trajectory of the user. However, because GPS data
can reveal sensitive information, such as a user’s location,
there are privacy concerns associated with its use. Therefore,
there’s a need to devise a solution that safeguards GPS data
from potential adversaries. Although multiple techniques for
calculating bearing are documented in the literature, this paper
presents a secure method, called GeoSecure-B, for calculating
bearing based on GPS coordinates while preserving user location
privacy. Our methodology is assessed using Microsoft’s GeoLife
dataset, demonstrating that our results closely align with bearings
calculated from methodologies utilizing real GPS coordinates.
Keywords-Bearing; Location Privacy; LBS; GPS
I. INTRODUCTION
Location-Based Services (LBS) applications are proliferat-
ing daily, especially with the widespread adoption of smart-
phones. Users increasingly depend on LBS for their everyday
tasks, but the real-time location tracking by LBS providers
commonly raises concerns regarding “location privacy” among
users [1].
Typically, LBS providers continuously monitor users’
Global Positioning System (GPS) trajectory data and transmit
it to their servers, frequently hosted on cloud platforms. Con-
sequently, the risk of unauthorized access to users’ personal
GPS data is heightened during data transportation, storage,
and other processes. Additionally, some LBS providers may
even sell this data to third-party companies, further exacer-
bating privacy risks. Moreover, there’s the potential for semi-
malicious or inquisitive entities to access this data. GPS data
presents various avenues for misuse. It can readily disclose
users’ home and work locations, visited places, traveled routes,
and more. Additionally, sensitive details such as political or
religious affiliations, healthcare providers, banking informa-
tion, shopping habits, and others can be readily inferred from
GPS trajectories. In extreme instances, such as persistent user
tracking, it can pose serious risks like illegal surveillance,
stalking, or other criminal activities [2]. Given the alarming
surge in cybersecurity incidents, it is imperative to safeguard
users’ location data not only from external threats but also
from potential misuse by LBS providers or their personnel
[3].
The bearing between two locations, depicted by their in-
dividual GPS coordinates, indicates the direction the user
must follow to reach the destination. Bearing is the clockwise
angle from north ranging from 0 to 359 degrees. Ships,
airplanes, drones, and autonomous/self-driving cars, robots
are some of the popular use cases for calculating bearing
for navigation. Sudden turns often signify aggressive driving
behaviors, with intoxicated drivers frequently exhibiting sharp
maneuvers. Data cleaning algorithms, like GeoSClean [4], can
also leverage bearing detection to eliminate abnormal GPS
points and enhance data quality. Bearing can also be used
for determining similarity in two trajectories [5], and in lossy
trajectory compression [6]. Given its relevance across various
applications, determining bearing stands as a significant prob-
lem.
There are several methods in the literature that are proposed
for calculating bearing between two locations [7]–[12]. Some
methods utilize sensors directly, while others rely on GPS
coordinates and compute it through the bearing calculation
formula. However, their primary focus does not lie on the
aspect of location privacy.
Therefore, in this paper, we introduce a novel approach,
named GeoSecure-B, which calculates the bearing between
two locations utilizing their GPS data points while preserving
location privacy. The GeoSecure-B method builds upon our
earlier research, GeoSecure-R [13], which establishes a secure
trajectory mirroring the original trajectory from the user. This
is accomplished by transmitting only the differences between
successive points of a GPS trajectory to the LBS provider,
employing a random GPS point within a large region to con-
struct a corresponding trajectory based on those differences,
and then calculating the bearing angle on the secure trajectory.
In this way, the actual coordinates of the user are never sent
to the LBS providers, and we can still provide the bearing
calculation service. We assess the efficacy of the proposed
approach using Microsoft’s GeoLife dataset [14]. To the best
of our knowledge, this is the first paper that focuses on the
calculation of GPS bearing while preserving location privacy.
The rest of the paper is organized as follows: Section
II presents a review of the related work and Section III
discusses the proposed method. Section IV gives detailed
implementation and results. Finally, conclusions along with
future work are discussed in section V.
TABLE I: A comparative analysis of proposed work with the
existing approaches for bearing calculation
Work Goal Location Privacy?
Hurgoiu et.al. [7] Navigation No
Du et al. [8] Intelligent detection of
subgrade compaction No
Sweeney [9] Path planning for
autonomous vehicles No
Feher and
Forstner [10] GPS tracklog compression No
Eftelioglu et al.
[12] Trip modalities classification No
Kasture et al.
[11]
Multi tracking system for
vehicle using GPS and GSM No
Al-Faiz and
Mahameda [15] Navigation No
Proposed Work Secure bearing calculation Yes
II. RELATED WORK
In this section we discuss the past works on bearing cal-
culation and compare them with the proposed method. In [7],
Hurgoiu et al. discussed the bearing calculation formula in
the context of real-time self-monitoring support. The bearing
is calculated as part of the digital compass data that provides
navigation monitoring. Also, in [8], Du et al. proposed an
improved GPS range measurement model using the bearing
calculation formula. The proposed GPS range measurement
model has smaller concentrated measurement errors and bet-
ter than the traditional GPS measurement model which has
relatively large error which is also an added advantage for the
compaction process quality control.
Further, in [9], Sweeney et al. proposed a classical navi-
gation techniques processed with GPS receivers data both the
latitude and longitude, along with the electronic compass angle
(determine heading angle) to provide the heading informa-
tion. They used closed-loop control strategies and stated that
they are effective in accurately measuring and dynamically
controlling the heading angle, position, and bearing angle.
They use the difference between the angles to determine if the
robot is approaching the destination. Also, in [10], Feher and
Forstner used GPS coordinates bearing as well as haversine
distance to compress GPS trajectories. Additionally, in [11],
Kasture et al. proposed a multi-tracking system for vehicles
using GPS and Global System for Mobile Communications
(GSM). They discussed the bearing calculation in tracking and
determining location. In another work, Al-Faiz and Mahameda
[15] presented a graph traversal and path finding algorithm
for a robot to traverse between location points using the GPS,
IR sensors, and digital compass. Based on heading readings
of the compass, the Proportional-Integral Device Controller is
adjusted such that the robot can move in a straight manner.
Recently, Eftelioglu et al. [12], presented an Long Short-
term Memory (LSTM) based model for Frequent Activity
Classification Network (FACNet) for travel modalities, i.e., the
mode of transportation such as driving and walking. In this
model, they used bearing as one of the features. The value of
the feature is based on left versus the fast right turns.
In the previously mentioned works concerning bearing
calculation, the primary emphasis lies in utilizing bearing for
applications like compression, mode detection, path planning,
and more. However, these approaches often overlook the
aspect of user security and privacy. In contrast, the method
proposed here prioritizes the secure calculation of bearing
between two GPS points while safeguarding user privacy.
Numerous strategies have been proposed in literature for
processing GPS data while maintaining privacy. Some widely
recognized approaches include obfuscation [16], masking [17],
differential privacy [18] and cryptography-based techniques
such as homomorphic encryption and secure multi-party com-
putation [19]. In [20], Armstrong et al. elaborated on displace-
ment masks and the properties like distance, direction etc.
that can be preserved using this transformation. Displacement
masks displace every point of the trajectory by a fixed value
and create a displaced trajectory.
Our past research also introduced a set of novel method-
ologies. Specifically, in the work titled GeoSecure [21], we
presented innovative techniques for computing distance, ve-
locity, and acceleration by adapting the haversine formula
[22], enhancing accuracy in GeoSecure-O [23]. Additionally,
in GeoSecure-R [13], we further refined distance calculation
accuracy by employing a secured trajectory, mirroring the
shape of the original plaintext trajectory, resulting in superior
accuracy. The key distinction between displacement masking
and GeoSecure-R lies in the fact that in GeoSecure-R, the
LBS provider has no involvement in determining the masking
function, and it represents an irreversible transformation as
the starting point of the trajectory remains unknown to the
LBS provider. In these methodologies, the initial point of
the trajectory is stored on the user’s device, while the dis-
crepancies between successive points are transmitted to the
LBS provider. The research outlined in this paper builds upon
the foundation of the GeoSecure-R approach, introducing a
fresh dimension in the form of bearing calculation. Table I
illustrates a comparative analysis between previous studies and
the research introduced in this paper.
III. PROPOSED METHOD
A. Definitions
Definition 1: (Trajectory) A GPS trajectory T is a sequen-
tial collection of GPS points, comprising latitude, longitude,
and time information. It is represented as: T= P1,P2,...,Pn,
where each point Pi,1 ≤ i ≤ n is expressed as a triplet
(lati,loni,timei), indicating latitude, longitude, and time,
respectively.
Definition 2: (Secure Trajectory) A secure GPS trajectory
T′
= P′
1,P′
2,...,P′
n is an altered form of the trajectory T that
conceals the user’s location while still facilitating the delivery
of a requested service.
B. Calculating Bearing using Original Trajectory
As the time component is generally unnecessary for calcu-
lating bearing angles, from now on, only latitude and longitude
information will be considered [7], [11], [24]. For a given pair
Fig. 1: GeoSecure-B workflow
of GPS data points Pi and Pj with coordinates (lati,loni) and
(latj ,lonj ) respectively the bearing angle θi,j between them
is calculated as follows:
dloni,j= lonj− loni
dlati,j= latj− lati
θi,j= atan2(αi,j ,βi,j ) (1)
where,
αi,j = cos(lati) × sin(latj )− sin(lati)
× cos(latj ) × cos(dloni,j ),
βi,j = sin(dloni,j ) × cos(latj )
C. Creating Secure Trajectory
Figure 1 outlines the workflow of the proposed method. The
GeoSecure-R [13] approach to transform a GPS trajectory T
into a secure GPS trajectory T′ is summarized as follows:
• Store the first point of the trajectory T on the users device.
• Multiply latitude and longitude of every GPS point by 106
.
In this way, we get rid of the decimal point.
• Starting from the second point of the trajectory, subtract
latitude and longitude of every point from its predecessor
point, so that we have differences between consecutive
points. Store the first point on the user’s device and send
the differences to the LBS provider.
• The LBS provider uses any random point (latR,lonR) in
that large geographical region R, preferably the center of
the region. Now, we add the first point of the series of
difference to the center point and get the corresponding
point. We repeat this process, i.e., adding every point of
differences to its predecessor point and in this way, create a
corresponding trajectory which is similar in shape but at a
different location. We call this a secured trajectory T′. Fig
2 depicts a trajectory and its secure trajectory after applying
GeoSecure-R method. Any point P′(lat′
i,lon′
i) on trajectory
T′ is calculated as:
lat′
i = latR +
i
k=1
dlatk,k+1 (2)
Fig. 2: Visualization of original trajectory T and its secured
trajectory T′ by using GeoSecure-R
lon′
i = lonR +
i
dlonk,k+1 (3)
k=1
D. Bearing Calculation with Location Privacy
The angle θ′
i,i+1 between two consecutive points
P′
i (lat′
i,lon′
i) and P′
i+1(lat′
i+1,lon′
i+1) on the secure
trajectory T′ is calculated as follows:
θ′
i,i+1 = atan2(α′
i,i+1,β′
i,i+1) (4)
where,
α′
i,i+1 = cos(latR + i
k=1 dlatk,k+1)
× sin(latR + i+1
k=1 dlatk,k+1)
− sin(latR + i
k=1 dlatk,k+1)
× cos(latR + i+1
k=1 dlatk,k+1)
× cos(dloni,i+1),
β′
i,i+1 = sin(dloni,i+1)
× cos(latR + i+1
k=1 dlatk,k+1)
IV. IMPLEMENTATION AND RESULTS
To evaluate the proposed method, we have used Microsoft’s
GeoLife [14] dataset. This dataset is a large publicly available
dataset collected by 182 users in Beijing, China and consists
of more than 18,000 trajectories. We selected 135 trajectories
from the dataset, and each trajectory contained thousands
of GPS points. Every trajectory undergoes transformation
into a secured trajectory through the GeoSecure-R method.
Subsequently, for each trajectory, we compute the bearing
between every pair of consecutive points from the original
trajectory. We then compare this with the bearing computed
from the secured trajectory and quantify the resulting error.
The average error resulting from GeoSecure-B method is
calculated as follows:
ϵavg =
n
i=1
θi,i+1− θ′
i,i+1 (5)
where θ and θ′ are calculated using Equation (1) and (4),
respectively, ϵ is the average error in bearing calculation.
TABLE II: For trajectory id ‘20090702091404.plt’: An illustration of first few points of the trajectory T in Beijing, China,
and its corresponding points of the trajectory T′ in different graphical regions
T in Beijing, China T ′ in Beijing, China T ′ in Albany, NY, USA T ′ in Iqaluit, NU, Canada T ′ in Cape Town, South Africa
(39.986803,116.299495) (39.913818,116.363625) (42.652580,-73.756233) (63.748611,-68.519722) (-33.918861,18.423300)
(39.986817 116.299505) (39.913831,116.363635) (42.652593,-73.756223) (63.748624,-68.519712) (-33.918848,18.423310)
(39.986828,116.299512) (39.913843,116.363642) (42.652605,-73.756216) (63.748636,-68.519705) (-33.918836,18.423317)
(39.986800,116.299542) (39.913815,116.363672) (42.652577,-73.756186) (63.748608,-68.519675) (-33.918864,18.423347)
TABLE III: For trajectory id ‘20090702091404.plt’: ϵerr (in degree) when for creating the secure trajectory the point
(latR,lonR) is chosen in four different geographical regions.
Region Beijing, China Albany, NY, USA Iqaluit, NU, Canada Cape Town, South Africa
Consecutive Points 0.01496 0.57495 7.8442 1.1136
Points chosen in steps of 50 0.01632 0.6262 8.3868 1.2182
Points chosen in steps of 100 0.01696 0.6501 8.5320 1.2684
Points chosen in steps of 1000 0.0154 0.5834 6.6279 1.1775
TABLE IV: For trajectory id ‘20120630110007.plt’: ϵerr (in degree) when for creating the secure trajectory the point
(latR,lonR) is chosen in four different geographical regions.
Region Beijing, China Albany, NY, USA Iqaluit, NU, Canada Cape Town, South Africa
Consecutive Points 0.01496 0.5936 7.8433 1.1585
Points chosen in steps of 50 0.01632 0.6974 9.0424 1.3657
Points chosen in steps of 100 0.01696 0.6880 9.2497 1.3345
Points chosen in steps of 1000 0.01540 0.6944 10.9012 1.2988
As T and T′ maintain a similar shape, the bearing (θ)
between corresponding pairs of points in T and T′ closely
correspond. Consequently, the disparity between their bearings
will be minimal. Fig. 3 illustrates the original trajectory T and
the secured trajectory T′with a reference point R selected in
Beijing, China. The secured trajectory T′ exhibits a similar
appearance if point Rwere chosen in Albany, NY (as depicted
in Fig. 4), Cape Town, SA (as shown in Fig. 5), or Iqaluit,
CA (as demonstrated in Fig. 6).
Table II shows the first few points of the original tra-
jectory T and its corresponding trajectories T′ in the re-
gions Beijing, Albany, Iqaluit, and Cape Town. For these
regions, latitudes and longitudes of the point R chosen are
as follows: (39.913818,116.363625) in Beijing, (42.652580,-
73.756233) in Albany, (63.748611,-68.519722) in Iqaluit, and
(-33.918861,18.423300) in Cape Town.
Table III displays the absolute average error in bearing
calculation for trajectory ‘20090702091404.plt’, considering
every pair of successive points, points in pairs at intervals of
50, 100, and 1000 for Beijing, Albany, Cape Town, and Iqaluit.
Similarly, Table IV presents the same data for trajectory
‘120630110007.plt’. We also evaluated the proposed method
on 135 trajectories from the Geolife dataset. For successive
points, the average error in bearing calculation is 0.2701; for
GPS points in steps of 50, it’s 0.247; for steps of 100, it’s
0.250; and for steps of 1000, it’s 0.237. It is noticeable that
the error is diminished when the point Raligns with the same
region as the original trajectory T, such as in the instance
of Beijing, where the error is 0.02 degrees. However, as the
distance from the original trajectory increases, so does the
error in bearing calculation. In certain scenarios, particularly
when the point R is nearer to the polar regions, the error es-
calates significantly, for example, reaching around 10 degrees
in Iqaluit. For real world applications, we recommend aiming
for errors below 1 deg in practical applications, considering
factors like object speed and distance traveled.
In Fig. 7, we present a visualization of ϵavg (ob-
tained using from Equation 5) for a specific trajectory, i.e.,
‘20081002160000.plt’. We can observe that the error is con-
siderably small, i.e., around 1 degree. Figure 8 illustrates the
bearing between pairs of GPS points taken at intervals of 1000
points for the trajectory ‘20081002160000.plt’. The overlap-
ping of bearing values indicates precise calculation, signifying
the proposed method’s high accuracy in securely computing
bearings. Thus, we can infer that the proposed method effec-
tively achieves accurate bearing calculations while maintaining
location privacy.
A. Discussion On Location Privacy
In this work, we consider the user to be honest. However,
the cloud service provider and LBS provider are considered
to be semi-malicious/curious, i.e., they provide the service as
specified, but try to know about the user. All other entities
are considered to be malicious. The communication between
user’s device and the LBS provider is also considered to be
secure.
In the proposed method, the user’s precise location remains
undisclosed to the service provider, with only the variances
between consecutive points being shared. Consequently, it
can be concluded that this approach safeguards the user’s
location privacy not just from external threats but also from
semi-malicious or curious LBS providers. We can argue that
the adversary might try to match the trajectory with map
and identify the user’s location. In this scenario, to enhance
privacy, we can divide the trajectory into smaller, uniform
segments. Each segment would be labeled with a unique
Fig. 3: Original trajectory T in Beijing, China
Fig. 4: Secure trajectory T′in Albany, NY, USA, corresponding
to original trajectory T
Fig. 5: Secure trajectory T′ in Cape Town, South Africa,
corresponding to original trajectory T
Fig. 6: Secure trajectory T′in Iqaluit, NU, Canada, correspond-
ing to original trajectory T
Fig. 7: Average error ϵerr in bearing calculation, x-axis
representing the points of the trajectory, and y-axis denotes
the error
Fig. 8: A comparison of bearing calculation for original and
secure trajectory for steps of 1000 points
random number and transmitted to the service provider in
random order, necessitating segment identifier management
on the user’s end. The total number of segments S for a
trajectory T with length n would be (n / segment length).
These segments can be arranged in S! permutations, offering
considerable variability. For instance, with S set at 20, the
trajectory could have over 2 quintillion different constructions,
and in turn enhance the location privacy.
B. Limitations
The accuracy of the proposed method is notably enhanced
when point Raligns with the same geographical region as the
original trajectory T. Nevertheless, as outlined in Table III and
Table IV, the error in bearing calculation escalates consider-
ably when point R approaches polar regions, as observed in
the instance of Iqaluit.
V. CONCLUSION
Based on our research, we determine that performing
bearing calculations using users’ GPS data can be achieved
without the need to know their precise location. Consequently,
this task can be executed while safeguarding their location
privacy. The GeoSecure-B methods effectively achieve this.
Such a method can act as a foundational component for
various algorithms, including mode detection, data cleaning,
compression algorithms, and more. Moving forward, we aim
to expand this method to include aggressive driving detection.
REFERENCES
[1] S. C. Shelby Brennan and B. Nussbaum, “The brave new world of third
party location data,” Journal of Strategic Security, vol. 16, no. 2, pp.
81–95, 2023.
[2] K. Orland, “CBS news article regarding stackers using GPS,” https:
//www.cbsnews.com/news/stalker-victims-should-check-for-gps/.
[3] D. Suo, M. E. Renda, and J. Zhao, “Quantifying the tradeoff between
cybersecurity and location privacy,” arXiv preprint arXiv:2105.01262,
2021.
[4] V. Patil, P. Singh, S. Parikh, and P. K. Atrey, “GeoSClean: Secure
cleaning of GPS trajectory data using anomaly detection,” in The 1st
IEEE Conference on Multimedia Information Processing and Retrieval
(MIPR), Miami, FL, USA, 2018, pp. 166–169.
[5] A. C. Pesara, V. Patil, and P. K. Atrey, “Secure computing of GPS
trajectory similarity: a review,” in The 2nd LocalRec Workshop at
The 26th ACM International Conference on Advances in Geographic
Information Systems (SIGSPATIAL), Seattle, WA, USA, 2018, pp. 3:1–
3:7.
[6] V. Patil, S. Parikh, O. N. Kulkarni, K. Bhatia, and P. K. Atrey,
“GeoSecure-C: A method for secure GPS trajectory compression over
cloud,” in The 9th IEEE Conference on Communications and Network
Security (CNS), 2021, pp. 1–2.
[7] D. Hurgoiu, V. Tompa, C. Neamt¸u, and D. Popescu, “Low-cost GPS
navigation for NXT-based robots,” Calitatea, vol. 13, no. 5, p. 371,
2012.
[8] W. Y. Du, W. P. Song, D. C. Feng, and L. H. Zhang, “Study on GPS
ranging technology for intelligent detection of subgrade compaction,”
Applied Mechanics and Materials, vol. 220, pp. 1533–1538, 2012.
[9] D. M. Sweeney, “GPS-based navigation of an ackerman
drive robot,” California State University, Sacramento, 2013.
[Online]. Available: https://scholars.csus.edu/esploro/outputs/graduate/
GPS-based-navigation-of-an-Ackerman-drive/99257831035801671#
file-0
[10] M. Feher and B. Forstner, “Self-adjusting method for efficient GPS
tracklog compression,” in The 4th IEEE International Conference on
Cognitive Infocommunications (CogInfoCom), Budapest, Hungary, 2013,
pp. 753–758.
[11] Y. Kasture, S. Gandhi, S. Gundawar, and A. Kulkarni, “Multi-tracking
system for vehicle using GPS and GSM,” International Journal of
Research in Engineering and Technology (IJRET), vol. 3, no. 3, 2014.
[12] E. Eftelioglu, G. Wolff, S. K. T. Nimmagadda, V. Kumar, and A. R.
Chowdhury, “Deep classification of frequently-changing activities from
GPS trajectories,” in The 15th ACM SIGSPATIAL International Work-
shop on Computational Transportation Science, Seattle, WA, USA,
2022, pp. 1–10.
[13] V. Patil and P. K. Atrey, “GeoSecure-R: Secure computation of geo-
graphical distance using region-anonymized GPS data,” in The 6th IEEE
International Conference on Multimedia Big Data (BigMM), New Delhi,
India, 2020, pp. 348–356.
[14] Y. Zheng, H. Fu, X. Xie, W.-Y. Ma, and Q. Li, Geolife
GPS Trajectory Dataset - User Guide, July 2011. [On-
line]. Available: https://www.microsoft.com/en-us/research/publication/
geolife-gps-trajectory-dataset-user-guide/
[15] M. Z. Al-Faiz and G. E. Mahameda, “GPS-based navigated autonomous
robot,” International Journal of Emerging Trends in Engineering Re-
search, vol. 3, no. 4, 2015.
[16] I. Ullah and M. A. Shah, “Sgo: Semantic group obfuscation for location-
based services in vanets,” Sensors, vol. 24, no. 4, p. 1145, 2024.
[17] Y. Lin, “Geo-indistinguishable masking: enhancing privacy protection
in spatial point mapping,” Cartography and Geographic Information
Science, vol. 50, no. 6, pp. 608–623, 2023.
[18] J. Zhang, Q. Huang, Y. Huang, Q. Ding, and P.-W. Tsai, “Dp-trajgan:
A privacy-aware trajectory generation model with differential privacy,”
Future Generation Computer Systems, vol. 142, pp. 25–40, 2023.
[19] K. Sahinbas and F. O. Catak, “Secure multi-party computation-based
privacy-preserving data analysis in healthcare iot systems,” in Inter-
pretable Cognitive Internet of Things for Healthcare. Springer, 2023,
pp. 57–72.
[20] M. Armstrong, G. Rushton, and D. Zimmerman, “Geographically mask-
ing health data to preserve confidentiality,” Statistics in Medicine,
vol. 18, no. 5, pp. 497–525, 1999.
[21] V. Patil, S. Parikh, P. Singh, and P. K. Atrey, “GeoSecure: Towards
secure outsourcing of GPS data over cloud,” in The 5th IEEE Conference
on Communications and Network Security (CNS), Las Vegas, NV, USA,
2017, pp. 495–501.
[22] R. Sinnott, “Virtues of the haversine,” Sky and Telescope, vol. 68, p.
159, 1984.
[23] V. Patil, S. B. Parikh, and P. K. Atrey, “GeoSecure-O: A method for
secure distance calculation for travel mode detection using outsourced
GPS trajectory data,” in The 5th IEEE International Conference on
Multimedia Big Data (BigMM), Singapore, 2019, pp. 348–356.
[24] “Movable type scripts,” https://www.movable-type.co.uk/scripts/latlong.
html.